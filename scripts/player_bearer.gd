class_name ProductionBearer
extends "res://scripts/player_animated.gd"

func _ready() -> void:
	super()
	sprite_sheet = load("res://art/production/bearer-weight-states-v1.png")
	queue_redraw()

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
	var walk_bob := sin(motion_time * 13.0) * 2.0 if absf(velocity.x) > 20.0 and is_on_floor() else sin(motion_time * 2.1) * 0.7
	var stretch := clampf(-velocity.y / 1800.0, -0.08, 0.1)
	var sx := 1.0 + squash * 0.38 - stretch * 0.35
	var sy := 1.0 - squash + stretch
	draw_ellipse_shadow(Vector2(0, 2), lerpf(25.0, 42.0, float(weight - 2) / 8.0))
	if exchange_flash > 0.0:
		draw_circle(Vector2(0, -46), 50.0 + (1.0 - exchange_flash) * 24.0, Color(0.47, 0.79, 0.81, exchange_flash * 0.24))
	draw_set_transform(Vector2(0, walk_bob), 0.0, Vector2(sx, sy))
	draw_texture_rect_region(sprite_sheet, Rect2(-width * 0.5, -height, width, height), source)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

