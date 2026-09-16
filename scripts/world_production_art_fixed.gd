extends "res://scripts/world_first_session.gd"
const BearerType = preload("res://scripts/player_bearer.gd")
var production_background: Texture2D
var visual_time := 0.0

func _ready() -> void:
	production_background = load("res://art/production/measure-hall-background-v1.png")
	super()
	queue_redraw()

func _process(delta: float) -> void:
	visual_time += delta
	super(delta)
	if not wind_zones.is_empty(): queue_redraw()

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
		draw_wind_zone(float(zone[0]), float(zone[1]), float(zone[2]))

	if needs_break and broken:
		var item = room_layout.fragile[0]
		draw_rect(Rect2(float(item[0]), float(item[1]), float(item[2]), 940.0 - float(item[1])), Color("8edcf6"))
		for i in range(8):
			var splash_x := float(item[0]) + 16.0 + i * 22.0
			draw_circle(Vector2(splash_x, float(item[1]) + 18.0 + (i % 2) * 10.0), 5.0, Color(1, 1, 1, 0.65))

func draw_wind_zone(start: float, finish: float, force: float) -> void:
	# Wind is invisible in real life, so sell it through moving streaks, dust and nearby motion.
	# Positive force is a headwind that travels from right to left.
	var span := maxf(80.0, finish - start)
	var speed := 150.0 + force * 0.12
	var alpha := clampf(0.28 + force / 3000.0, 0.3, 0.62)

	# Sparse animated streamlines. No colored rectangle: the air itself appears to move.
	for row in range(7):
		var y := 430.0 + row * 31.0
		var lane_phase := fposmod(visual_time * speed + row * 83.0, span + 160.0)
		var head_x := finish + 80.0 - lane_phase
		for repeat in range(2):
			var x := head_x + repeat * (span * 0.58)
			if x < start - 90.0 or x > finish + 90.0: continue
			var wobble := sin(visual_time * 3.0 + row * 0.8) * 5.0
			var points := PackedVector2Array([
				Vector2(x + 82, y - 8 + wobble),
				Vector2(x + 55, y - 2),
				Vector2(x + 24, y + 3 - wobble * 0.25),
				Vector2(x - 12, y + 1),
				Vector2(x - 44, y + 7 + wobble * 0.2),
			])
			draw_polyline(points, Color(1, 1, 1, alpha), 2.2, true)

	# Small drifting debris makes wind strength legible without looking like a UI effect.
	for i in range(10):
		var drift := fposmod(visual_time * (115.0 + i * 4.0) + i * 97.0, span + 90.0)
		var x := finish + 45.0 - drift
		if x < start - 25.0 or x > finish + 25.0: continue
		var y := 465.0 + float((i * 37) % 150) + sin(visual_time * 4.0 + i) * 7.0
		var size := 2.0 + float(i % 3)
		draw_circle(Vector2(x, y), size, Color("b6caa8", 0.55))
		draw_line(Vector2(x + 7, y - 2), Vector2(x - 8, y + 3), Color(1, 1, 1, 0.38), 1.5, true)

	# A subtle ground dust trail anchors the wind to the world.
	for i in range(6):
		var dust_x := finish - fposmod(visual_time * 95.0 + i * 71.0, span)
		var dust_y := 630.0 - float(i % 3) * 5.0
		draw_circle(Vector2(dust_x, dust_y), 4.0 + i % 2, Color(0.78, 0.86, 0.75, 0.18))
