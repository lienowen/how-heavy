class_name PerformanceBearer
extends "res://scripts/player_bearer.gd"

enum Pose { IDLE, WALK, TAKEOFF, RISE, FALL, LAND, EXCHANGE, IMPACT, FAILURE, VICTORY }

var pose: Pose = Pose.IDLE
var pose_time := 0.0
var facing := 1.0
var forced_pose_time := 0.0
var previous_grounded := false
var previous_vertical_speed := 0.0
var stride_phase := 0.0
var wind_visual := 0.0

func _ready() -> void:
	super()
	previous_grounded = is_on_floor()
	exchanged.connect(play_exchange)
	heavy_impact.connect(func(_at: Vector2, _speed: float): play_impact())

func _physics_process(delta: float) -> void:
	var grounded_before := is_on_floor()
	var vertical_before := velocity.y
	var horizontal_before := velocity.x
	super(delta)
	pose_time += delta
	var weight_speed := 1.12 if weight <= 3 else (0.82 if weight >= 9 else 1.0)
	stride_phase += delta * clampf(absf(velocity.x) / 22.0, 4.0, 13.5) * weight_speed
	if absf(velocity.x) > 8.0: facing = signf(velocity.x)
	var target_wind := clampf(wind_force / 900.0, -1.0, 1.0)
	wind_visual = lerpf(wind_visual, target_wind, clampf(delta * 6.5, 0.0, 1.0))
	if forced_pose_time > 0.0:
		forced_pose_time -= delta
	else:
		select_locomotion_pose(grounded_before, vertical_before, horizontal_before)
	previous_grounded = is_on_floor()
	previous_vertical_speed = velocity.y
	queue_redraw()

func select_locomotion_pose(grounded_before: bool, vertical_before: float, horizontal_before: float) -> void:
	if not controls_enabled:
		if pose != Pose.FAILURE and pose != Pose.VICTORY: set_pose(Pose.IDLE)
		return
	if not grounded_before and is_on_floor() and vertical_before > 150.0:
		set_forced_pose(Pose.LAND, 0.16)
	elif grounded_before and not is_on_floor() and velocity.y < 0.0:
		set_forced_pose(Pose.TAKEOFF, 0.1)
	elif not is_on_floor():
		set_pose(Pose.RISE if velocity.y < 35.0 else Pose.FALL)
	elif absf(horizontal_before) > 18.0:
		set_pose(Pose.WALK)
	else:
		set_pose(Pose.IDLE)

func set_pose(next: Pose) -> void:
	if pose == next: return
	pose = next
	pose_time = 0.0

func set_forced_pose(next: Pose, duration: float) -> void:
	set_pose(next)
	forced_pose_time = duration

func play_exchange() -> void: set_forced_pose(Pose.EXCHANGE, 0.34)
func play_impact() -> void: set_forced_pose(Pose.IMPACT, 0.28)
func play_failure() -> void: set_forced_pose(Pose.FAILURE, 0.55)
func play_victory() -> void: set_forced_pose(Pose.VICTORY, 2.0)

func animation_name() -> String:
	return Pose.keys()[pose].to_lower()

func wind_responsiveness() -> float:
	if weight <= 3: return 1.25
	if weight >= 9: return 0.42
	return 0.78

func draw_wind_clothing(anchor: Vector2, response: float) -> void:
	if absf(wind_visual) < 0.04: return
	var trail_dir := -signf(wind_visual)
	var strength := absf(wind_visual) * response
	var flutter := sin(pose_time * (8.0 + strength * 5.0)) * (4.0 + strength * 4.0)
	var length := 30.0 + strength * 44.0
	var p0 := anchor
	var p1 := anchor + Vector2(trail_dir * length * 0.38, -3.0 + flutter * 0.25)
	var p2 := anchor + Vector2(trail_dir * length * 0.72, 3.0 - flutter * 0.45)
	var p3 := anchor + Vector2(trail_dir * length, 7.0 + flutter * 0.55)
	var cloth := PackedVector2Array([
		p0 + Vector2(0, -5), p1 + Vector2(0, -4), p2 + Vector2(0, -3), p3,
		p2 + Vector2(0, 4), p1 + Vector2(0, 5), p0 + Vector2(0, 5)
	])
	draw_colored_polygon(cloth, Color(ProductionTheme.CYAN, 0.88))

func _draw() -> void:
	if sprite_sheet == null: return

	var source := Rect2(700, 95, 590, 690)
	var height := 124.0
	var body_scale := Vector2(1.0, 1.0)
	var state_color := ProductionTheme.GREEN
	if weight <= 3:
		source = Rect2(90, 75, 590, 700)
		height = 132.0
		body_scale = Vector2(0.86, 1.08)
		state_color = ProductionTheme.CYAN
	elif weight >= 9:
		source = Rect2(1250, 175, 692, 620)
		height = 126.0
		body_scale = Vector2(1.24, 0.94)
		state_color = ProductionTheme.ORANGE

	var width := source.size.x / source.size.y * height
	var offset := Vector2.ZERO
	var rotation := 0.0
	var scale_value := Vector2.ONE
	var ring_scale := 1.0
	var stride := sin(stride_phase)
	var response := wind_responsiveness()
	var wind_strength := absf(wind_visual)

	match pose:
		Pose.IDLE:
			offset.y = sin(pose_time * (2.7 if weight <= 3 else 1.8)) * (1.4 if weight <= 3 else 0.7)
			rotation = sin(pose_time * 1.3) * 0.008
		Pose.WALK:
			var bob := 3.4 if weight <= 3 else (1.8 if weight >= 9 else 2.7)
			offset = Vector2(stride * 1.7, -absf(stride) * bob)
			rotation = stride * (0.045 if weight <= 3 else 0.028) * facing
			scale_value = Vector2(1.0 - absf(stride) * 0.018, 1.0 + absf(stride) * 0.025)
		Pose.TAKEOFF:
			scale_value = Vector2(1.1, 0.88)
			offset.y = 4.0
		Pose.RISE:
			scale_value = Vector2(0.93, 1.08)
			rotation = -0.045 * facing
		Pose.FALL:
			scale_value = Vector2(1.05, 0.94)
			rotation = 0.055 * facing
		Pose.LAND:
			var settle := 1.0 - clampf(pose_time / 0.16, 0.0, 1.0)
			var heavy_boost := 1.45 if weight >= 9 else 1.0
			scale_value = Vector2(1.0 + settle * 0.18 * heavy_boost, 1.0 - settle * 0.2 * heavy_boost)
			offset.y = settle * 7.0 * heavy_boost
		Pose.EXCHANGE:
			var wave := sin(clampf(pose_time / 0.34, 0.0, 1.0) * PI)
			scale_value = Vector2(1.0 - wave * 0.08, 1.0 + wave * 0.09)
			ring_scale = 1.0 + wave * 0.42
		Pose.IMPACT:
			var recoil := 1.0 - clampf(pose_time / 0.28, 0.0, 1.0)
			scale_value = Vector2(1.0 + recoil * 0.22, 1.0 - recoil * 0.18)
			offset.y = recoil * 6.0
		Pose.FAILURE:
			var fall := clampf(pose_time / 0.48, 0.0, 1.0)
			rotation = fall * 1.25 * facing
			offset = Vector2(10.0 * facing * fall, 20.0 * fall)
			scale_value = Vector2(1.0 + fall * 0.08, 1.0 - fall * 0.14)
		Pose.VICTORY:
			var lift := sin(clampf(pose_time / 0.42, 0.0, 1.0) * PI)
			offset.y = -lift * 8.0
			ring_scale = 1.0 + lift * 0.3

	if pose not in [Pose.FAILURE, Pose.VICTORY] and wind_strength > 0.03:
		rotation += wind_visual * deg_to_rad(9.5) * response
		offset.x += wind_visual * 4.0 * response
		if is_on_floor(): scale_value.y *= 1.0 - wind_strength * 0.025 * response

	var shadow_radius := lerpf(26.0, 51.0, float(weight - 2) / 8.0)
	if pose == Pose.RISE or pose == Pose.FALL: shadow_radius *= 0.82
	draw_ellipse_shadow(Vector2(0, 2), shadow_radius)

	if pose == Pose.EXCHANGE or pose == Pose.VICTORY:
		draw_arc(Vector2(0, -55) + offset, 54.0 * ring_scale, 0, TAU, 64, Color(state_color, 0.9), 4.0)

	draw_wind_clothing(Vector2(0, -height * 0.70) + offset, response)
	draw_set_transform(offset, rotation, Vector2(scale_value.x * body_scale.x * facing, scale_value.y * body_scale.y))
	draw_texture_rect_region(sprite_sheet, Rect2(-width * 0.5, -height, width, height), source)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
