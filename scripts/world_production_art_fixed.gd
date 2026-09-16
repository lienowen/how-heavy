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
	# Keep the authored texture subtle so the new bright chapter environment remains dominant.
	if production_background != null:
		var chapter := Campaign.chapter_for_level(level_id)
		var chapter_tints: Array[Color] = [Color(0.90, 0.98, 1.0, 0.15), Color(0.90, 1.0, 0.97, 0.14), Color(0.94, 0.94, 1.0, 0.14), Color(1.0, 0.95, 0.90, 0.14)]
		var tint: Color = chapter_tints[chapter - 1]
		for x: float in [0.0, 1280.0, 2560.0]:
			draw_texture_rect(production_background, Rect2(x, 0, 1280, 720), false, tint)

	# Light ground wash replaces the old dark industrial floor.
	draw_rect(Rect2(0, 640, 3550, 300), Color("dff4fb"))
	draw_rect(Rect2(0, 640, 3550, 12), Color("ffffff"))

	for child in get_children():
		if child is StaticBody2D and child.has_meta("rect") and child.visible:
			var local_rect: Rect2 = child.get_meta("rect")
			var target := Rect2(child.position.x + local_rect.position.x, child.position.y + local_rect.position.y, local_rect.size.x, local_rect.size.y)
			var fragile := bool(child.get_meta("fragile"))
			var body_color := Color("ffe1b8") if fragile else Color("f6fbff")
			var edge_color := ProductionTheme.ORANGE if fragile else Color("8bcdf4")
			draw_rect(target, body_color)
			draw_rect(Rect2(target.position, Vector2(target.size.x, minf(12.0, target.size.y))), edge_color, true)
			draw_line(target.position + Vector2(0, target.size.y - 1), target.end - Vector2(0, 1), Color(0.20, 0.45, 0.62, 0.12), 2)
			for mark_x in range(int(target.position.x) + 42, int(target.end.x), 84):
				draw_circle(Vector2(mark_x, target.position.y + 6), 2.5, Color(1, 1, 1, 0.86))

	for zone in wind_zones:
		var start := float(zone[0])
		var finish := float(zone[1])
		draw_rect(Rect2(start, 390, finish - start, 280), Color(ProductionTheme.CYAN, 0.07))
		for y in range(445, 650, 38):
			draw_line(Vector2(start + 30, y), Vector2(finish - 30, y - 16), Color(ProductionTheme.CYAN, 0.58), 3.0)

	if needs_break and broken:
		var item = room_layout.fragile[0]
		draw_rect(Rect2(float(item[0]), float(item[1]), float(item[2]), 940.0 - float(item[1])), Color("8edcf6"))
		for i in range(8):
			var splash_x := float(item[0]) + 16.0 + i * 22.0
			draw_circle(Vector2(splash_x, float(item[1]) + 18.0 + (i % 2) * 10.0), 5.0, Color(1, 1, 1, 0.65))
