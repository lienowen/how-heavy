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
	var radius := minf(size.x, size.y) * 0.36
	draw_circle(center, radius + 8.0, Color(0.03, 0.05, 0.06, 0.94))
	draw_arc(center, radius + 5.0, 0, TAU, 64, Color("665b3b"), 3.0)
	for i in range(9):
		var angle := deg_to_rad(-135.0 + i * 33.75)
		var active := i <= weight - 2
		var color := ProductionTheme.BRASS_BRIGHT if active else Color("425056")
		var inner := center + Vector2(cos(angle), sin(angle)) * (radius - 2.0)
		var outer := center + Vector2(cos(angle), sin(angle)) * (radius + (8.0 if active else 5.0))
		draw_line(inner, outer, color, 2.5 if active else 1.5, true)
	var hand_angle := deg_to_rad(-135.0 + (weight - 2) * 33.75)
	draw_line(center, center + Vector2(cos(hand_angle), sin(hand_angle)) * (radius - 5.0), ProductionTheme.CYAN, 3.0, true)
	draw_circle(center, 5.0, ProductionTheme.BRASS_BRIGHT)
	var number := str(weight)
	var font := ThemeDB.fallback_font
	var text_size := font.get_string_size(number, HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
	draw_string(font, center - Vector2(text_size.x * 0.5, -text_size.y * 0.34), number, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, ProductionTheme.IVORY)

