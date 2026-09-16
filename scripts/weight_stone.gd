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
	circle.radius = 43
	collision.shape = circle
	add_child(collision)
	queue_redraw()
func _draw() -> void:
	if active:
		draw_circle(Vector2.ZERO, 51, Color(0.98, 0.75, 0.23, 0.18))
	draw_circle(Vector2.ZERO, 38, Color("363836"))
	draw_circle(Vector2(-8, -8), 24, Color("555650"))
	draw_arc(Vector2.ZERO, 38, 0, TAU, 42, Color("f1c75b") if active else Color("8b7848"), 3)
	var label := str(weight)
	var font := ThemeDB.fallback_font
	var size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 24)
	draw_string(font, Vector2(-size.x * 0.5, 8), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("f7e8bd"))

