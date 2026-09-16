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
	stride_phase += delta * clampf(absf(velocity.x) / 22.0, 4.0, 13.5)
	if absf(velocity.x) > 8.0: facing = signf(velocity.x)
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

func _draw() -> void:
	if sprite_sheet == null: return
	var source := Rect2(700, 95, 590, 690)
	var height := 104.0
	if weight <= 3:
		source = Rect2(90, 75, 590, 700)
		height = 112.0
	elif weight >= 9:
		source = Rect2(1250, 175, 692, 620)
		height = 92.0
	var width := source.size.x / source.size.y * height
	var offset := Vector2.ZERO
	var rotation := 0.0
	var scale_value := Vector2.ONE
	var ring_scale := 1.0
	var stride := sin(stride_phase)
	match pose:
		Pose.IDLE:
			offset.y = sin(pose_time * 2.0) * 0.9
			rotation = sin(pose_time * 1.3) * 0.008
		Pose.WALK:
			offset = Vector2(stride * 1.5, -absf(stride) * 2.7)
			rotation = stride * 0.035 * facing
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
			scale_value = Vector2(1.0 + settle * 0.18, 1.0 - settle * 0.2)
			offset.y = settle * 7.0
		Pose.EXCHANGE:
			var wave := sin(clampf(pose_time / 0.34, 0.0, 1.0) * PI)
			scale_value = Vector2(1.0 - wave * 0.08, 1.0 + wave * 0.09)
			ring_scale = 1.0 + wave * 0.35
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
			ring_scale = 1.0 + lift * 0.25

	var shadow_radius := lerpf(25.0, 42.0, float(weight - 2) / 8.0)
	if pose == Pose.RISE or pose == Pose.FALL: shadow_radius *= 0.82
	draw_ellipse_shadow(Vector2(0, 2), shadow_radius)
	if pose == Pose.EXCHANGE or pose == Pose.VICTORY:
		draw_arc(Vector2(0, -48) + offset, 48.0 * ring_scale, 0, TAU, 64, Color(0.47, 0.79, 0.81, 0.86), 3.0)
		draw_arc(Vector2(0, -48) + offset, 57.0 * ring_scale, -PI * 0.7, PI * 0.3, 42, Color(0.88, 0.74, 0.4, 0.72), 2.0)
	draw_set_transform(offset, rotation, Vector2(scale_value.x * facing, scale_value.y))
	draw_texture_rect_region(sprite_sheet, Rect2(-width * 0.5, -height, width, height), source)
	if pose == Pose.WALK:
		draw_line(Vector2(-12, -4), Vector2(-12 + stride * 10.0, 2), Color("d7b85a"), 3)
		draw_line(Vector2(12, -4), Vector2(12 - stride * 10.0, 2), Color("d7b85a"), 3)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

