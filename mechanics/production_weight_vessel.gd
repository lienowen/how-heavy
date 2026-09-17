class_name ProductionWeightVessel
extends ReleaseStone

var pulse := 0.0

func _process(delta: float) -> void:
	pulse += delta * (3.2 if active else 1.1)
	if active: queue_redraw()

func _draw() -> void:
	if active:
		var glow := 0.12 + sin(pulse * 1.5) * 0.025
		draw_circle(Vector2(0, -8), 54, Color(weight_color(), glow))
		draw_arc(Vector2(0, -8), 49, 0, TAU, 48, Color(weight_color(), 0.55), 3)

	if weight <= 3:
		draw_light_crate()
	elif weight >= 9:
		draw_heavy_block()
	else:
		draw_balanced_pack()

func draw_light_crate() -> void:
	var box := Rect2(-37, -50, 74, 62)
	draw_rect(box, Color("c98a4b"), true)
	draw_rect(box, Color("7e4e28"), false, 4)
	draw_line(Vector2(-31, -43), Vector2(31, 5), Color("a66a38"), 5, true)
	draw_line(Vector2(31, -43), Vector2(-31, 5), Color("a66a38"), 5, true)
	draw_line(Vector2(-24, -50), Vector2(-24, 12), Color("e0ad6e"), 3)
	draw_line(Vector2(24, -50), Vector2(24, 12), Color("8b572f"), 3)
	# Feather icon: the light object should read instantly without looking like UI.
	draw_line(Vector2(-8, -25), Vector2(9, -39), Color("fff8db"), 4, true)
	draw_line(Vector2(-6, -27), Vector2(-13, -36), Color("fff8db"), 3, true)
	draw_line(Vector2(0, -32), Vector2(-3, -43), Color("fff8db"), 3, true)
	draw_line(Vector2(4, -35), Vector2(12, -34), Color("fff8db"), 3, true)
	draw_weight_number(Vector2(0, 3), Color("fff6dc"), Color("6d3f22"))

func draw_balanced_pack() -> void:
	var body := Rect2(-34, -56, 68, 68)
	draw_style_box(make_box(Color("5c876a"), Color("365844"), 4, 14), body)
	draw_arc(Vector2(0, -52), 23, PI, TAU, 24, Color("365844"), 5)
	draw_line(Vector2(-21, -39), Vector2(-29, 3), Color("d7e3ca"), 5, true)
	draw_line(Vector2(21, -39), Vector2(29, 3), Color("d7e3ca"), 5, true)
	draw_rect(Rect2(-14, -23, 28, 17), Color("456b53"), true)
	draw_rect(Rect2(-14, -23, 28, 17), Color("d8b66a"), false, 3)
	draw_weight_number(Vector2(0, 3), Color("f6f3da"), Color("294536"))

func draw_heavy_block() -> void:
	var body := Rect2(-43, -49, 86, 61)
	draw_style_box(make_box(Color("59636c"), Color("252d34"), 4, 9), body)
	draw_rect(Rect2(-27, -64, 54, 17), Color("303942"), true)
	draw_rect(Rect2(-18, -61, 36, 10), Color("8a969d"), true)
	for x in [-31.0, 31.0]:
		for y in [-37.0, 0.0]:
			draw_circle(Vector2(x, y), 3.5, Color("c9d0d2"))
	draw_line(Vector2(-31, -30), Vector2(31, -30), Color("75818a"), 3)
	draw_weight_number(Vector2(0, 4), Color("fff1cf"), Color("1e272e"))

func draw_weight_number(center: Vector2, text_color: Color, shadow_color: Color) -> void:
	var label := str(weight)
	var font := ThemeDB.fallback_font
	var text_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 25)
	var at := center + Vector2(-text_size.x * 0.5, 8)
	draw_string(font, at + Vector2(2, 2), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 25, shadow_color)
	draw_string(font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 25, text_color)

func make_box(fill: Color, border: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(radius)
	return box
