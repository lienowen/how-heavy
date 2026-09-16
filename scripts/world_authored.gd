extends "res://scripts/world_finale.gd"

var room_layout: Dictionary
var wind_zones: Array = []

func build_level() -> void:
	room_layout = LevelLayouts.room(level_id)
	wind_zones = room_layout.wind
	for item in room_layout.platforms:
		make_platform(Rect2(float(item[0]), float(item[1]), float(item[2]), float(item[3])))
	for item in room_layout.stones:
		make_stone(Vector2(float(item[0]), float(item[1])), int(item[2]))
	for item in room_layout.gates:
		add_pressure_gate(Vector2(float(item[0]), float(item[1])), Vector2(float(item[2]), float(item[3])), int(item[4]))
	for item in room_layout.movers:
		add_moving_platform(Vector2(float(item[0]), float(item[1])), Vector2(float(item[2]), float(item[3])), float(item[4]), level_id * 0.17)
	for item in room_layout.springs:
		add_spring(Vector2(float(item[0]), float(item[1])), float(item[2]))
	needs_break = not room_layout.fragile.is_empty()
	if needs_break:
		var item = room_layout.fragile[0]
		fragile = make_platform(Rect2(float(item[0]), float(item[1]), float(item[2]), float(item[3])), true)
	else:
		fragile = make_platform(Rect2(5000, 900, 10, 10), false)
		fragile.visible = false

func _process(delta: float) -> void:
	if not finished and not respawning and not get_tree().paused: elapsed += delta
	stats_label.text = "ROOM %02d / 24     %.1fs  -  %d trades  -  %d falls" % [level_id, elapsed, exchanges, deaths]
	if not is_instance_valid(player): return
	player.wind_force = active_wind_force(player.position.x)
	update_interaction()
	update_checkpoint()
	var chapter := Campaign.chapter_for_level(level_id)
	chapter_label.text = "%s  /  %s" % [Campaign.CHAPTERS[chapter - 1].title, level_info.name.to_upper()]
	if player.position.x > 3440 and (not needs_break or broken) and not finished: complete_slice()

func active_wind_force(x: float) -> float:
	for zone in wind_zones:
		if x >= float(zone[0]) and x <= float(zone[1]): return float(zone[2])
	return 0.0

func _draw() -> void:
	draw_texture_rect(background, Rect2(0, 0, 3550, 940), false)
	draw_rect(Rect2(0, 0, 3550, 940), Color(0.01, 0.02, 0.035, 0.1))
	for child in get_children():
		if child is StaticBody2D and child.has_meta("rect") and child.visible:
			var rect: Rect2 = child.get_meta("rect")
			var target := Rect2(child.position.x + rect.position.x, child.position.y + rect.position.y - 14, rect.size.x, minf(maxf(rect.size.y, 70), 150))
			var source := Rect2(15, 520, 510, 245) if bool(child.get_meta("fragile")) else Rect2(10, 185, 1070, 240)
			draw_texture_rect_region(kit, target, source)
	for zone in wind_zones:
		var start := float(zone[0])
		var finish := float(zone[1])
		draw_rect(Rect2(start, 390, finish - start, 280), Color(0.18, 0.7, 0.84, 0.08))
		for y in range(445, 650, 38): draw_line(Vector2(start + 30, y), Vector2(finish - 30, y - 16), Color(0.52, 0.86, 0.92, 0.72), 3)
	if needs_break and broken:
		var item = room_layout.fragile[0]
		draw_rect(Rect2(float(item[0]), float(item[1]), float(item[2]), 940.0 - float(item[1])), Color(0.005, 0.008, 0.012, 0.95))
