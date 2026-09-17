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
	# Wind is invisible: nearby objects provide the strongest visual reference.
	# Positive force in gameplay pushes toward the left, so fabric and debris trail left.
	var span := maxf(80.0, finish - start)
	var speed := 150.0 + absf(force) * 0.12
	var alpha := clampf(0.24 + absf(force) / 3200.0, 0.28, 0.58)
	var wind_dir := -1.0 if force >= 0.0 else 1.0
	var strength := clampf(absf(force) / 900.0, 0.25, 1.0)

	# Flag poles at the beginning/middle/end make direction obvious before the player enters.
	for i in range(3):
		var pole_x := lerpf(start + 45.0, finish - 45.0, float(i) / 2.0)
		draw_wind_flag(Vector2(pole_x, 636.0), wind_dir, strength, i)

	# Grass tufts bend with the same wind. This keeps the air connected to the ground plane.
	for i in range(11):
		var grass_x := start + 24.0 + fposmod(float(i * 61), maxf(70.0, span - 45.0))
		draw_wind_grass(Vector2(grass_x, 640.0), wind_dir, strength, i)

	# Sparse animated streamlines. No colored rectangle: the air itself appears to move.
	for row in range(7):
		var y := 430.0 + row * 31.0
		var lane_phase := fposmod(visual_time * speed + row * 83.0, span + 160.0)
		var head_x := finish + 80.0 - lane_phase if wind_dir < 0.0 else start - 80.0 + lane_phase
		for repeat in range(2):
			var x := head_x + repeat * (span * 0.58) * -wind_dir
			if x < start - 90.0 or x > finish + 90.0: continue
			var wobble := sin(visual_time * 3.0 + row * 0.8) * 5.0
			var points := PackedVector2Array([
				Vector2(x - wind_dir * 82.0, y - 8 + wobble),
				Vector2(x - wind_dir * 55.0, y - 2),
				Vector2(x - wind_dir * 24.0, y + 3 - wobble * 0.25),
				Vector2(x + wind_dir * 12.0, y + 1),
				Vector2(x + wind_dir * 44.0, y + 7 + wobble * 0.2),
			])
			draw_polyline(points, Color(1, 1, 1, alpha), 2.2, true)

	# Leaves/paper scraps are stronger references than abstract particles.
	for i in range(12):
		var drift := fposmod(visual_time * (118.0 + i * 4.0) + i * 89.0, span + 110.0)
		var x := finish + 55.0 - drift if wind_dir < 0.0 else start - 55.0 + drift
		if x < start - 30.0 or x > finish + 30.0: continue
		var y := 458.0 + float((i * 37) % 158) + sin(visual_time * 4.5 + i) * 9.0
		var angle := visual_time * (2.0 + i * 0.08) + i
		var leaf_len := 8.0 + float(i % 3) * 2.0
		var tangent := Vector2(cos(angle), sin(angle)) * leaf_len
		draw_line(Vector2(x, y) - tangent * 0.5, Vector2(x, y) + tangent * 0.5, Color("8fbd72", 0.72), 3.0, true)
		if i % 4 == 0:
			var paper := Rect2(Vector2(x - 4.0, y - 3.0), Vector2(9.0, 6.0))
			draw_rect(paper, Color(1, 1, 1, 0.72), true)

	# Ground dust drifts in exactly the same direction as flags and leaves.
	for i in range(7):
		var phase := fposmod(visual_time * 96.0 + i * 71.0, span)
		var dust_x := finish - phase if wind_dir < 0.0 else start + phase
		var dust_y := 630.0 - float(i % 3) * 5.0
		draw_circle(Vector2(dust_x, dust_y), 4.0 + i % 2, Color(0.78, 0.86, 0.75, 0.18))

func draw_wind_flag(base: Vector2, wind_dir: float, strength: float, index: int) -> void:
	var pole_height := 78.0
	var top := base + Vector2(0, -pole_height)
	draw_line(base, top, Color("60859b"), 4.0, true)
	draw_circle(base, 5.0, Color("8bcdf4"))
	var flutter := sin(visual_time * (6.0 + strength * 4.0) + index * 1.7) * (5.0 + strength * 5.0)
	var length := 38.0 + strength * 34.0
	var p0 := top + Vector2(0, 7)
	var p1 := p0 + Vector2(wind_dir * length * 0.42, flutter * 0.35)
	var p2 := p0 + Vector2(wind_dir * length * 0.74, -flutter * 0.3 + 8.0)
	var p3 := p0 + Vector2(wind_dir * length, flutter * 0.45 + 4.0)
	var flag := PackedVector2Array([
		p0,
		p1 + Vector2(0, -8),
		p2 + Vector2(0, -5),
		p3,
		p2 + Vector2(0, 9),
		p1 + Vector2(0, 10),
	])
	draw_colored_polygon(flag, Color(ProductionTheme.ORANGE, 0.82))
	draw_polyline(PackedVector2Array([p0, p1, p2, p3]), Color(1, 1, 1, 0.6), 1.5, true)

func draw_wind_grass(base: Vector2, wind_dir: float, strength: float, index: int) -> void:
	var sway := wind_dir * (8.0 + strength * 15.0)
	var flutter := sin(visual_time * 5.0 + index * 0.9) * 2.2 * strength
	for blade in range(3):
		var origin := base + Vector2((blade - 1) * 4.0, 0)
		var height := 15.0 + blade * 4.0
		var tip := origin + Vector2(sway + flutter + blade * wind_dir * 2.0, -height)
		draw_line(origin, tip, Color("63b879", 0.72), 2.2, true)
