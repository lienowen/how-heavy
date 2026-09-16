class_name WeightDial
extends Control

var weight := 6:
	set(value):
		weight = clampi(value, 2, 10)
		queue_redraw()

func _ready() -> void:
	custom_minimum_size = Vector2(72, 72)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.34
	var accent := ProductionTheme.CYAN if weight <= 3 else (ProductionTheme.ORANGE if weight >= 9 else ProductionTheme.GREEN)

	draw_circle(center, radius + 10.0, Color(1, 1, 1, 0.98))
	draw_circle(center, radius + 7.0, Color(accent, 0.12))
	draw_arc(center, radius + 6.0, 0, TAU, 64, Color(accent, 0.72), 3.0)

	for i in range(9):
		var angle := deg_to_rad(-135.0 + i * 33.75)
		var active := i <= weight - 2
		var color := accent if active else Color("c8d9e3")
		var inner := center + Vector2(cos(angle), sin(angle)) * (radius - 2.0)
		var outer := center + Vector2(cos(angle), sin(angle)) * (radius + (8.0 if active else 5.0))
		draw_line(inner, outer, color, 3.0 if active else 1.5, true)

	var hand_angle := deg_to_rad(-135.0 + (weight - 2) * 33.75)
	draw_line(center, center + Vector2(cos(hand_angle), sin(hand_angle)) * (radius - 5.0), accent, 4.0, true)
	draw_circle(center, 6.0, accent)

	var number := str(weight)
	var font := ThemeDB.fallback_font
	var text_size := font.get_string_size(number, HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
	draw_string(font, center - Vector2(text_size.x * 0.5, -text_size.y * 0.34), number, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, ProductionTheme.INK)
