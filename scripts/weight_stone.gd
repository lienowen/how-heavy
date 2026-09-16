class_name ReleaseStone
extends Area2D

var weight := 2:
	set(value):
		weight = value
		queue_redraw()

var active := false:
	set(value):
		active = value
		queue_redraw()

func setup(at: Vector2, value: int) -> void:
	position = at
	weight = value
	add_to_group("release_stones")
	var collision := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 45
	collision.shape = circle
	add_child(collision)
	queue_redraw()

func weight_color() -> Color:
	if weight <= 3:
		return ProductionTheme.CYAN
	if weight >= 9:
		return ProductionTheme.ORANGE
	return ProductionTheme.GREEN

func _draw() -> void:
	var accent := weight_color()

	# Platform-friendly presentation: bright capsule, large number, clear active state.
	if active:
		draw_circle(Vector2.ZERO, 58, Color(accent, 0.16))
		draw_arc(Vector2.ZERO, 54, 0, TAU, 64, Color(accent, 0.42), 5)

	draw_circle(Vector2.ZERO, 42, Color(1, 1, 1, 0.98))
	draw_circle(Vector2.ZERO, 39, Color(accent, 0.16))
	draw_arc(Vector2.ZERO, 42, 0, TAU, 56, Color(accent, 0.95), 4)

	# Small top badge reinforces the interaction affordance without extra text clutter.
	draw_circle(Vector2(0, -33), 10, accent)
	draw_circle(Vector2(0, -33), 4, Color.WHITE)

	var label := str(weight)
	var font := ThemeDB.fallback_font
	var size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 30)
	draw_string(font, Vector2(-size.x * 0.5, 11), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, ProductionTheme.INK)

	var caption := "LIGHT" if weight <= 3 else ("HEAVY" if weight >= 9 else "BALANCED")
	var caption_size := font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
	draw_string(font, Vector2(-caption_size.x * 0.5, 29), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(accent, 0.95))
