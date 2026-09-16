extends "res://scripts/world_first_session.gd"
const BearerType = preload("res://scripts/player_bearer.gd")
var production_background: Texture2D

func _ready() -> void:
	production_background = load("res://art/production/measure-hall-background-v1.png")
	super()
	queue_redraw()

func spawn_player() -> void:
	player = BearerType.new()
	player.position = START
	add_child(player)
	player.weight_changed.connect(update_weight)
	player.exchanged.connect(func(): exchanges += 1)
	player.fell_out.connect(on_fell)
	player.heavy_impact.connect(on_impact)
	var camera := Camera2D.new()
	camera.position = Vector2(0, -250)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 6
	camera.limit_left = 0
	camera.limit_right = 3550
	camera.limit_top = 0
	camera.limit_bottom = 940
	player.add_child(camera)
	update_weight(player.weight)

func _draw() -> void:
	if production_background != null:
		var chapter := Campaign.chapter_for_level(level_id)
		var chapter_tints: Array[Color] = [Color("dbe3df"), Color("cbd9d8"), Color("d4cedd"), Color("dfc9b0")]
		var tint: Color = chapter_tints[chapter - 1]
		for x: float in [0.0, 1280.0, 2560.0]: draw_texture_rect(production_background, Rect2(x, 0, 1280, 720), false, tint)
	draw_rect(Rect2(0, 640, 3550, 300), Color(0.025, 0.035, 0.04, 0.18))
	for child in get_children():
		if child is StaticBody2D and child.has_meta("rect") and child.visible:
			var local_rect: Rect2 = child.get_meta("rect")
			var target := Rect2(child.position.x + local_rect.position.x, child.position.y + local_rect.position.y, local_rect.size.x, local_rect.size.y)
			var fragile_color := Color("54483b") if bool(child.get_meta("fragile")) else Color("172329")
			draw_rect(target, fragile_color)
			draw_rect(Rect2(target.position, Vector2(target.size.x, minf(10.0, target.size.y))), Color("b89a52"), true)
			for mark_x in range(int(target.position.x) + 36, int(target.end.x), 72): draw_line(Vector2(mark_x, target.position.y), Vector2(mark_x, target.position.y + 9), Color("e0c06b"), 2.0)
	for zone in wind_zones:
		var start := float(zone[0])
		var finish := float(zone[1])
		draw_rect(Rect2(start, 390, finish - start, 280), Color(0.28, 0.72, 0.75, 0.06))
		for y in range(445, 650, 38): draw_line(Vector2(start + 30, y), Vector2(finish - 30, y - 16), Color(0.47, 0.79, 0.81, 0.55), 2.0)
	if needs_break and broken:
		var item = room_layout.fragile[0]
		draw_rect(Rect2(float(item[0]), float(item[1]), float(item[2]), 940.0 - float(item[1])), Color(0.005, 0.008, 0.012, 0.92))

