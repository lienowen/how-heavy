extends "res://scripts/world_first_session.gd"
const BearerType = preload("res://scripts/player_bearer.gd")
var visual_time := 0.0

func _ready() -> void:
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
	camera.position = Vector2(0, -225)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7
	camera.limit_left = 0
	camera.limit_right = 3550
	camera.limit_top = 0
	camera.limit_bottom = 940
	player.add_child(camera)
	update_weight(player.weight)

func _draw() -> void:
	# The playfield is scenery now, not UI rectangles.
	for child in get_children():
		if child is StaticBody2D and child.has_meta("rect") and child.visible:
			var local_rect: Rect2 = child.get_meta("rect")
			var target := Rect2(child.position.x + local_rect.position.x, child.position.y + local_rect.position.y, local_rect.size.x, local_rect.size.y)
			var fragile := bool(child.get_meta("fragile"))
			if fragile:
				draw_fragile_platform(target)
			else:
				draw_stone_platform(target)

	for zone in wind_zones:
		draw_wind_zone(float(zone[0]), float(zone[1]), float(zone[2]))

	if needs_break and broken:
		var item = room_layout.fragile[0]
		var gap := Rect2(float(item[0]), float(item[1]), float(item[2]), 940.0 - float(item[1]))
		draw_rect(gap, Color("75c9e8"))
		for i in range(7):
			draw_circle(Vector2(gap.position.x + 18 + i * 25, gap.position.y + 22 + (i % 2) * 10), 5, Color(1,1,1,0.42))

func draw_stone_platform(rect: Rect2) -> void:
	# grass cap
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, minf(12.0, rect.size.y))), Color("6ebd66"), true)
	draw_rect(Rect2(rect.position + Vector2(0,8), Vector2(rect.size.x, minf(8.0, rect.size.y))), Color("4f9f54"), true)

	# stone body
	var body := Rect2(rect.position + Vector2(0,12), Vector2(rect.size.x, maxf(0.0, rect.size.y - 12)))
	draw_rect(body, Color("a8a59a"), true)
	var stone_w := 58.0
	var stone_h := 34.0
	var rows := int(ceil(body.size.y / stone_h))
	var cols := int(ceil(body.size.x / stone_w))
	for row in range(rows):
		for col in range(cols):
			var offset_x := 0.0 if row % 2 == 0 else stone_w * 0.5
			var x := body.position.x + col * stone_w - offset_x
			var y := body.position.y + row * stone_h
			var cell := Rect2(x + 2, y + 2, stone_w - 5, stone_h - 5)
			if cell.end.x < body.position.x or cell.position.x > body.end.x: continue
			cell.position.x = maxf(cell.position.x, body.position.x)
			cell.size.x = minf(cell.end.x, body.end.x) - cell.position.x
			var shade := Color("b9b5a8") if (row + col) % 3 == 0 else Color("9f9c91")
			draw_rect(cell, shade, true)
			draw_rect(cell, Color(0.22,0.25,0.25,0.22), false, 1.5)

	# small plants break up long platforms
	for x in range(int(rect.position.x) + 40, int(rect.end.x), 155):
		var base := Vector2(x, rect.position.y + 1)
		draw_line(base, base + Vector2(-8,-14), Color("4c9958"), 2.2, true)
		draw_line(base + Vector2(4,0), base + Vector2(10,-12), Color("5aac65"), 2.2, true)

func draw_fragile_platform(rect: Rect2) -> void:
	draw_rect(rect, Color("c9824d"), true)
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, minf(9.0, rect.size.y))), Color("efb067"), true)
	for x in range(int(rect.position.x) + 12, int(rect.end.x), 26):
		draw_line(Vector2(x, rect.position.y + 8), Vector2(x + 12, rect.position.y + rect.size.y - 5), Color("8e5939"), 2.0)
		draw_line(Vector2(x + 12, rect.position.y + rect.size.y - 5), Vector2(x + 20, rect.position.y + 13), Color("8e5939"), 2.0)

func draw_wind_zone(start: float, finish: float, force: float) -> void:
	var span := maxf(80.0, finish - start)
	var speed := 150.0 + absf(force) * 0.12
	var alpha := clampf(0.20 + absf(force) / 3600.0, 0.22, 0.44)
	var wind_dir := -1.0 if force >= 0.0 else 1.0
	var strength := clampf(absf(force) / 900.0, 0.25, 1.0)

	for i in range(2):
		var pole_x := lerpf(start + 48.0, finish - 48.0, float(i))
		draw_wind_flag(Vector2(pole_x, 636.0), wind_dir, strength, i)

	for i in range(9):
		var grass_x := start + 24.0 + fposmod(float(i * 63), maxf(70.0, span - 45.0))
		draw_wind_grass(Vector2(grass_x, 640.0), wind_dir, strength, i)

	for row in range(4):
		var y := 455.0 + row * 42.0
		var phase := fposmod(visual_time * speed + row * 103.0, span + 150.0)
		var x := finish + 70.0 - phase if wind_dir < 0.0 else start - 70.0 + phase
		if x >= start - 80.0 and x <= finish + 80.0:
			var wobble := sin(visual_time * 3.2 + row) * 4.0
			var pts := PackedVector2Array([
				Vector2(x - wind_dir * 72.0, y - 5 + wobble),
				Vector2(x - wind_dir * 34.0, y + 2),
				Vector2(x + wind_dir * 8.0, y - 1)
			])
			draw_polyline(pts, Color(1,1,1,alpha), 2.0, true)

	for i in range(10):
		var drift := fposmod(visual_time * (112.0 + i * 5.0) + i * 91.0, span + 100.0)
		var x := finish + 50.0 - drift if wind_dir < 0.0 else start - 50.0 + drift
		if x < start - 30.0 or x > finish + 30.0: continue
		var y := 470.0 + float((i * 41) % 145) + sin(visual_time * 4.2 + i) * 8.0
		var tangent := Vector2(cos(visual_time * 2.2 + i), sin(visual_time * 2.2 + i)) * 8.0
		draw_line(Vector2(x,y)-tangent*0.5, Vector2(x,y)+tangent*0.5, Color("6f9d58",0.78), 3.0, true)

func draw_wind_flag(base: Vector2, wind_dir: float, strength: float, index: int) -> void:
	var top := base + Vector2(0, -82)
	draw_line(base, top, Color("6f523a"), 4.0, true)
	var flutter := sin(visual_time * (6.0 + strength * 4.0) + index * 1.7) * (4.0 + strength * 5.0)
	var length := 40.0 + strength * 34.0
	var p0 := top + Vector2(0, 7)
	var p1 := p0 + Vector2(wind_dir * length * 0.5, flutter * 0.25)
	var p2 := p0 + Vector2(wind_dir * length, flutter * 0.5 + 5.0)
	var flag := PackedVector2Array([p0+Vector2(0,-6), p1+Vector2(0,-5), p2, p1+Vector2(0,7), p0+Vector2(0,7)])
	draw_colored_polygon(flag, Color("d65347"))

func draw_wind_grass(base: Vector2, wind_dir: float, strength: float, index: int) -> void:
	var sway := wind_dir * (7.0 + strength * 14.0)
	var flutter := sin(visual_time * 5.0 + index * 0.9) * 2.0 * strength
	for blade in range(4):
		var origin := base + Vector2((blade - 2) * 3.5, 0)
		var tip := origin + Vector2(sway + flutter + blade * wind_dir, -(15.0 + blade * 3.0))
		draw_line(origin, tip, Color("459b55", 0.9), 2.0, true)
