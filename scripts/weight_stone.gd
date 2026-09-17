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
	var shape := RectangleShape2D.new()
	shape.size = Vector2(78, 72)
	collision.shape = shape
	collision.position = Vector2(0, -28)
	add_child(collision)
	queue_redraw()

func weight_color() -> Color:
	if weight <= 3: return ProductionTheme.CYAN
	if weight >= 9: return ProductionTheme.ORANGE
	return ProductionTheme.GREEN

func _draw() -> void:
	var accent := weight_color()
	if active:
		draw_circle(Vector2(0, -32), 64, Color(accent, 0.12))
		draw_arc(Vector2(0, -32), 58, 0, TAU, 48, Color(accent, 0.48), 4.0)

	if weight <= 3:
		draw_light_crate(accent)
	elif weight >= 9:
		draw_heavy_block(accent)
	else:
		draw_balanced_pack(accent)

func draw_light_crate(accent: Color) -> void:
	var rect := Rect2(-38, -66, 76, 62)
	draw_rect(rect, Color("d99a58"), true)
	draw_rect(Rect2(-34, -62, 68, 54), Color("f0b96d"), true)
	draw_line(Vector2(-34,-62), Vector2(34,-8), Color("b8733e"), 5)
	draw_line(Vector2(34,-62), Vector2(-34,-8), Color("b8733e"), 5)
	draw_rect(Rect2(-38,-66,76,62), Color("9f6338"), false, 4)
	# feather mark
	draw_line(Vector2(-7,-48), Vector2(10,-25), Color.WHITE, 4, true)
	draw_line(Vector2(-4,-43), Vector2(8,-45), Color.WHITE, 3, true)
	draw_line(Vector2(0,-37), Vector2(13,-38), Color.WHITE, 3, true)
	draw_weight_badge(accent, Vector2(0,-3))

func draw_balanced_pack(accent: Color) -> void:
	var body := Rect2(-34, -70, 68, 66)
	draw_rect(body, Color("8d684e"), true)
	draw_rect(Rect2(-28,-64,56,52), Color("b88a66"), true)
	draw_arc(Vector2(0,-68), 20, PI, TAU, 24, Color("6e5140"), 5)
	draw_line(Vector2(-22,-55), Vector2(-30,-14), Color("6e5140"), 5, true)
	draw_line(Vector2(22,-55), Vector2(30,-14), Color("6e5140"), 5, true)
	draw_rect(Rect2(-17,-43,34,22), Color("d4ad82"), true)
	draw_weight_badge(accent, Vector2(0,-6))

func draw_heavy_block(accent: Color) -> void:
	var rect := Rect2(-40, -64, 80, 60)
	draw_rect(rect, Color("59636f"), true)
	draw_rect(Rect2(-34,-58,68,48), Color("76818e"), true)
	draw_rect(Rect2(-40,-64,80,60), Color("39434c"), false, 4)
	for x in [-29.0, 29.0]:
		for y in [-51.0, -17.0]: draw_circle(Vector2(x,y), 4, Color("c2cbd2"))
	# handle
	draw_line(Vector2(-16,-64), Vector2(-16,-76), Color("39434c"), 6, true)
	draw_line(Vector2(16,-64), Vector2(16,-76), Color("39434c"), 6, true)
	draw_line(Vector2(-16,-76), Vector2(16,-76), Color("39434c"), 6, true)
	draw_weight_badge(accent, Vector2(0,-5))

func draw_weight_badge(accent: Color, at: Vector2) -> void:
	draw_circle(at + Vector2(0,-26), 22, Color(0.08,0.12,0.16,0.92))
	draw_arc(at + Vector2(0,-26), 22, 0, TAU, 32, accent, 3)
	var font := ThemeDB.fallback_font
	var label := str(weight)
	var size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 22)
	draw_string(font, at + Vector2(-size.x * 0.5, -18), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
