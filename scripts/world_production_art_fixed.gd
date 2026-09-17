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
	camera.position = Vector2(0, -235)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 6
	camera.limit_left = 0
	camera.limit_right = 3550
	camera.limit_top = 0
	camera.limit_bottom = 940
	player.add_child(camera)
	update_weight(player.weight)

func _draw() -> void:
	# No legacy background texture here. The chapter environment is the only backdrop.
	# A very light floor tint keeps gaps readable without creating a giant white slab.
	draw_rect(Rect2(0, 642, 3550, 298), Color(0.80, 0.93, 0.96, 0.26))

	for child in get_children():
		if child is StaticBody2D and child.has_meta("rect") and child.visible:
			var local_rect: Rect2 = child.get_meta("rect")
			var target := Rect2(child.position.x + local_rect.position.x, child.position.y + local_rect.position.y, local_rect.size.x, local_rect.size.y)
			var fragile := bool(child.get_meta("fragile"))
			var body_color := Color("ffe0b2") if fragile else Color("f7fbfd")
			var edge_color := ProductionTheme.ORANGE if fragile else Color("5db7e8")
			draw_rect(target, body_color)
			draw_rect(Rect2(target.position, Vector2(target.size.x, minf(10.0, target.size.y))), edge_color, true)
			draw_line(target.position + Vector2(0, target.size.y - 1), target.end - Vector2(0, 1), Color(0.14, 0.36, 0.48, 0.16), 2)

	for zone in wind_zones:
		draw_wind_zone(float(zone[0]), float(zone[1]), float(zone[2]))

	if needs_break and broken:
		var item = room_layout.fragile[0]
		draw_rect(Rect2(float(item[0]), float(item[1]), float(item[2]), 940.0 - float(item[1])), Color("8edcf6"))

func draw_wind_zone(start: float, finish: float, force: float) -> void:
	var span := maxf(80.0, finish - start)
	var speed := 150.0 + absf(force) * 0.12
	var alpha := clampf(0.22 + absf(force) / 3400.0, 0.24, 0.48)
	var wind_dir := -1.0 if force >= 0.0 else 1.0
	var strength := clampf(absf(force) / 900.0, 0.25, 1.0)

	# Only wind zones get flags/grass. Decorative flags were removed from the rest of the level.
	for i in range(2):
		var pole_x := lerpf(start + 52.0, finish - 52.0, float(i))
		draw_wind_flag(Vector2(pole_x, 636.0), wind_dir, strength, i)

	for i in range(8):
		var grass_x := start + 26.0 + fposmod(float(i * 67), maxf(70.0, span - 45.0))
		draw_wind_grass(Vector2(grass_x, 640.0), wind_dir, strength, i)

	for row in range(5):
		var y := 445.0 + row * 36.0
		var phase := fposmod(visual_time * speed + row * 97.0, span + 150.0)
		var x := finish + 70.0 - phase if wind_dir < 0.0 else start - 70.0 + phase
		if x >= start - 80.0 and x <= finish + 80.0:
			var wobble := sin(visual_time * 3.2 + row) * 4.0
			var pts := PackedVector2Array([
				Vector2(x - wind_dir * 72.0, y - 5 + wobble),
				Vector2(x - wind_dir * 34.0, y + 2),
				Vector2(x + wind_dir * 8.0, y - 1),
			])
			draw_polyline(pts, Color(1, 1, 1, alpha), 2.0, true)

	for i in range(8):
		var drift := fposmod(visual_time * (112.0 + i * 5.0) + i * 91.0, span + 100.0)
		var x := finish + 50.0 - drift if wind_dir < 0.0 else start - 50.0 + drift
		if x < start - 30.0 or x > finish + 30.0: continue
		var y := 470.0 + float((i * 41) % 145) + sin(visual_time * 4.2 + i) * 8.0
		var tangent := Vector2(cos(visual_time * 2.2 + i), sin(visual_time * 2.2 + i)) * 8.0
		draw_line(Vector2(x, y) - tangent * 0.5, Vector2(x, y) + tangent * 0.5, Color("77aa62", 0.74), 3.0, true)

	for i in range(5):
		var dust_phase := fposmod(visual_time * 92.0 + i * 79.0, span)
		var dust_x := finish - dust_phase if wind_dir < 0.0 else start + dust_phase
		draw_circle(Vector2(dust_x, 632.0 - float(i % 2) * 5.0), 4.0, Color(0.76, 0.80, 0.70, 0.18))

func draw_wind_flag(base: Vector2, wind_dir: float, strength: float, index: int) -> void:
	var top := base + Vector2(0, -72)
	draw_line(base, top, Color("54788d"), 3.0, true)
	var flutter := sin(visual_time * (6.0 + strength * 4.0) + index * 1.7) * (4.0 + strength * 5.0)
	var length := 34.0 + strength * 30.0
	var p0 := top + Vector2(0, 6)
	var p1 := p0 + Vector2(wind_dir * length * 0.5, flutter * 0.3)
	var p2 := p0 + Vector2(wind_dir * length, flutter * 0.55 + 5.0)
	var flag := PackedVector2Array([p0 + Vector2(0,-5), p1 + Vector2(0,-4), p2, p1 + Vector2(0,6), p0 + Vector2(0,6)])
	draw_colored_polygon(flag, Color(ProductionTheme.ORANGE, 0.86))

func draw_wind_grass(base: Vector2, wind_dir: float, strength: float, index: int) -> void:
	var sway := wind_dir * (7.0 + strength * 13.0)
	var flutter := sin(visual_time * 5.0 + index * 0.9) * 2.0 * strength
	for blade in range(3):
		var origin := base + Vector2((blade - 1) * 4.0, 0)
		var tip := origin + Vector2(sway + flutter + blade * wind_dir, -(14.0 + blade * 4.0))
		draw_line(origin, tip, Color("4f9e67", 0.80), 2.0, true)
