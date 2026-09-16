class_name AnimatedReleasePlayer
extends "res://scripts/player.gd"

var motion_time := 0.0
var squash := 0.0
var exchange_flash := 0.0
var previous_weight := 6
var was_grounded := false

func _ready() -> void:
	super()
	previous_weight = weight
	was_grounded = is_on_floor()

func _physics_process(delta: float) -> void:
	var grounded_before := is_on_floor()
	var vertical_before := velocity.y
	super(delta)
	motion_time += delta
	exchange_flash = maxf(0.0, exchange_flash - delta * 3.5)
	squash = move_toward(squash, 0.0, delta * 4.5)
	if not grounded_before and is_on_floor() and vertical_before > 180.0:
		squash = clampf(vertical_before / 900.0, 0.12, 0.4)
		burst(Color("d7b85a"), 12, Vector2(1.0, 0.25))
	if weight != previous_weight:
		exchange_flash = 1.0
		squash = -0.22
		burst(Color("9de8ed") if weight <= 3 else Color("e3b85c"), 24, Vector2(0.8, 0.8))
		previous_weight = weight
	queue_redraw()

func burst(color: Color, amount: int, spread: Vector2) -> void:
	var particles := CPUParticles2D.new()
	particles.one_shot = true
	particles.amount = amount
	particles.lifetime = 0.42
	particles.explosiveness = 0.9
	particles.direction = Vector2(0, -1)
	particles.spread = 170.0
	particles.initial_velocity_min = 45.0
	particles.initial_velocity_max = 135.0
	particles.gravity = Vector2(0, 210)
	particles.scale_amount_min = 1.5
	particles.scale_amount_max = 4.0
	particles.color = color
	particles.position = Vector2(0, -25)
	particles.scale = spread
	add_child(particles)
	particles.emitting = true
	get_tree().create_timer(0.7).timeout.connect(particles.queue_free)

func _draw() -> void:
	if sprite_sheet == null: return
	var source := Rect2(610, 120, 560, 710)
	if weight <= 3: source = Rect2(30, 35, 540, 790)
	elif weight >= 9: source = Rect2(1190, 175, 570, 650)
	var height := 100.0
	var width := source.size.x / source.size.y * height
	var walk_bob := sin(motion_time * 13.0) * 2.2 if absf(velocity.x) > 20.0 and is_on_floor() else sin(motion_time * 2.1) * 0.8
	var stretch := clampf(-velocity.y / 1800.0, -0.08, 0.1)
	var sx := 1.0 + squash * 0.42 - stretch * 0.4
	var sy := 1.0 - squash + stretch
	draw_ellipse_shadow(Vector2(0, 2), lerpf(28.0, 38.0, float(weight - 2) / 8.0))
	if exchange_flash > 0.0:
		draw_circle(Vector2(0, -48), 52.0 + (1.0 - exchange_flash) * 26.0, Color(0.55, 0.92, 0.95, exchange_flash * 0.22))
	draw_set_transform(Vector2(0, walk_bob), 0.0, Vector2(sx, sy))
	draw_texture_rect_region(sprite_sheet, Rect2(-width * 0.5, -height, width, height), source)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_ellipse_shadow(at: Vector2, radius: float) -> void:
	var points := PackedVector2Array()
	for i in range(25):
		var angle := TAU * i / 24.0
		points.append(at + Vector2(cos(angle) * radius, sin(angle) * 7.0))
	draw_colored_polygon(points, Color(0.0, 0.0, 0.0, 0.34))
