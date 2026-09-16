class_name MenuBackdrop
extends Control

var time := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 1.0 or h <= 1.0:
		return

	# Bright layered sky.
	draw_rect(Rect2(Vector2.ZERO, size), Color("eafaff"))
	draw_rect(Rect2(0, 0, w, h * 0.30), Color("71d9ff"))
	draw_rect(Rect2(0, h * 0.24, w, h * 0.22), Color("aeeaff"))
	draw_rect(Rect2(0, h * 0.42, w, h * 0.18), Color("dff8ff"))

	# Sun and soft halo.
	var sun := Vector2(w * 0.80, h * 0.17)
	draw_circle(sun, 72.0, Color(1.0, 0.91, 0.50, 0.18))
	draw_circle(sun, 48.0, Color("fff09a"))

	# Slow clouds keep the menu alive without visual noise.
	for i in range(7):
		var cloud_x := fposmod(i * 245.0 + time * (7.0 + i), w + 260.0) - 130.0
		var cloud_y := 70.0 + float((i * 67) % 180)
		draw_cloud(Vector2(cloud_x, cloud_y), 0.72 + float(i % 3) * 0.12)

	# Far city silhouette.
	var base_y := h * 0.58
	for i in range(18):
		var bw := 62.0 + float((i * 17) % 44)
		var bh := 62.0 + float((i * 43) % 120)
		var x := i * (w / 17.0) - 20.0
		draw_rect(Rect2(x, base_y - bh, bw, bh), Color("b7e6f2"))
		if i % 3 == 0:
			draw_rect(Rect2(x + bw * 0.24, base_y - bh - 24, bw * 0.52, 24), Color("a8dce9"))

	# Layered hills / park edge.
	var hill_back := PackedVector2Array([Vector2(0, h * 0.57)])
	for i in range(9):
		hill_back.append(Vector2(i * w / 8.0, h * (0.56 + 0.035 * sin(i * 1.2))))
	hill_back.append(Vector2(w, h))
	hill_back.append(Vector2(0, h))
	draw_colored_polygon(hill_back, Color("8cddb8"))

	var hill_front := PackedVector2Array([Vector2(0, h * 0.66)])
	for i in range(9):
		hill_front.append(Vector2(i * w / 8.0, h * (0.65 + 0.025 * cos(i * 1.1))))
	hill_front.append(Vector2(w, h))
	hill_front.append(Vector2(0, h))
	draw_colored_polygon(hill_front, Color("68c99d"))

	# Runner lane: clean, chunky and readable.
	var road_top_left := Vector2(w * 0.45, h * 0.56)
	var road_top_right := Vector2(w * 0.61, h * 0.56)
	var road_bottom_right := Vector2(w * 0.88, h)
	var road_bottom_left := Vector2(w * 0.22, h)
	var road := PackedVector2Array([road_top_left, road_top_right, road_bottom_right, road_bottom_left])
	draw_colored_polygon(road, Color("f7f7f2"))
	draw_polyline(PackedVector2Array([road_top_left, road_bottom_left]), Color("d8eef5"), 7.0)
	draw_polyline(PackedVector2Array([road_top_right, road_bottom_right]), Color("d8eef5"), 7.0)

	# Lane dashes.
	for i in range(5):
		var t := 0.12 + i * 0.17
		var y := lerpf(h * 0.59, h * 0.96, t)
		var half := lerpf(4.0, 14.0, t)
		draw_rect(Rect2(w * 0.53 - half, y, half * 2.0, 13.0 + t * 8.0), Color(1, 1, 1, 0.85))

	# Two oversized choice gates on the right communicate the game instantly.
	draw_gate(Vector2(w * 0.66, h * 0.47), Vector2(105, 160), Color("35cfd0"), "-10")
	draw_gate(Vector2(w * 0.80, h * 0.47), Vector2(105, 160), Color("ff9a42"), "+20")

	# Small decorative weight chips near the road.
	draw_weight_chip(Vector2(w * 0.70, h * 0.78), "20 kg", Color("35cfd0"))
	draw_weight_chip(Vector2(w * 0.83, h * 0.86), "40 kg", Color("ff9a42"))

func draw_cloud(at: Vector2, scale: float) -> void:
	var color := Color(1, 1, 1, 0.88)
	draw_circle(at + Vector2(-32, 9) * scale, 25 * scale, color)
	draw_circle(at + Vector2(0, -5) * scale, 34 * scale, color)
	draw_circle(at + Vector2(36, 8) * scale, 24 * scale, color)
	draw_rect(Rect2(at + Vector2(-48, 7) * scale, Vector2(96, 27) * scale), color)

func draw_gate(center: Vector2, gate_size: Vector2, color: Color, label_text: String) -> void:
	var left := center.x - gate_size.x * 0.5
	var top := center.y - gate_size.y * 0.5
	var post := 12.0
	draw_rect(Rect2(left, top, post, gate_size.y), color)
	draw_rect(Rect2(left + gate_size.x - post, top, post, gate_size.y), color)
	draw_rect(Rect2(left, top, gate_size.x, 16), color)
	draw_rect(Rect2(left + 8, top + 18, gate_size.x - 16, 55), Color(color, 0.18))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(center.x - 29, top + 57), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("17324d"))

func draw_weight_chip(center: Vector2, text_value: String, accent: Color) -> void:
	var rect := Rect2(center - Vector2(48, 18), Vector2(96, 36))
	draw_style_box(make_chip_box(accent), rect)
	var font := ThemeDB.fallback_font
	draw_string(font, center + Vector2(-31, 7), text_value, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("17324d"))

func make_chip_box(accent: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(1, 1, 1, 0.92)
	box.border_color = Color(accent, 0.75)
	box.set_border_width_all(2)
	box.corner_radius_top_left = 12
	box.corner_radius_top_right = 12
	box.corner_radius_bottom_left = 12
	box.corner_radius_bottom_right = 12
	return box
