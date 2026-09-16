extends "res://scripts/world_release.gd"

func _process(delta: float) -> void:
	if not finished and not respawning and not get_tree().paused: elapsed += delta
	stats_label.text = "%.1fs  ·  %d trades  ·  %d falls" % [elapsed, exchanges, deaths]
	if not is_instance_valid(player): return
	player.wind_force = 880.0 if player.position.x > 1260 and player.position.x < 1780 else 0.0
	update_interaction()
	update_checkpoint()
	chapter_label.text = "01 / LET GO" if player.position.x < 1200 else ("02 / HOLD FAST" if player.position.x < 2250 else "03 / FALL")
	if broken and player.position.x > 3370 and player.position.y > 760 and not finished: complete_slice()

func base_hint() -> String:
	return "A / D  MOVE    ·    SPACE  JUMP    ·    E  TRADE WEIGHT    ·    ESC  PAUSE"

func update_interaction() -> void:
	var nearest: ReleaseStone
	var best := 120.0
	for node in get_tree().get_nodes_in_group("release_stones"):
		var item := node as ReleaseStone
		var distance := player.position.distance_to(item.position)
		if distance < best: best = distance; nearest = item
	if player.nearby != nearest:
		if player.nearby != null: player.nearby.active = false
		player.nearby = nearest
		if nearest != null: nearest.active = true; hint_label.text = "E  ·  TRADE WITH WEIGHT %d" % nearest.weight
		else: hint_label.text = base_hint()

func update_checkpoint() -> void:
	var marks := [780.0, 1880.0, 2660.0]
	if checkpoint_stage < marks.size() and player.position.x >= marks[checkpoint_stage]:
		checkpoint = Vector2(marks[checkpoint_stage], 620 if checkpoint_stage < 2 else 490)
		checkpoint_weight = player.weight
		checkpoint_stage += 1
		hint_label.text = "CHECKPOINT RECORDED"

func update_weight(value: int) -> void:
	var quality := "LIGHT" if value <= 3 else ("HEAVY" if value >= 9 else "BALANCED")
	weight_label.text = "WEIGHT %d  ·  %s" % [value, quality]

func on_fell() -> void:
	if respawning or finished: return
	respawning = true
	deaths += 1
	player.controls_enabled = false
	hint_label.text = "FALLEN  ·  RETURNING TO CHECKPOINT"
	await get_tree().create_timer(0.55).timeout
	player.restore(checkpoint, checkpoint_weight)
	respawning = false
	hint_label.text = base_hint()

func complete_slice() -> void:
	finished = true
	player.controls_enabled = false
	Game.complete_level(1, elapsed, exchanges, deaths)
	result_label.text = "YOU MADE IT THROUGH.\n\n%.1f seconds  ·  %d trades  ·  %d falls\n\nR  TRY AGAIN     ESC  RETURN TO TITLE" % [elapsed, exchanges, deaths]
	result_panel.visible = true

func _draw() -> void:
	draw_texture_rect(background, Rect2(0, 0, 3550, 940), false)
	draw_rect(Rect2(0, 0, 3550, 940), Color(0.01, 0.02, 0.035, 0.08))
	for child in get_children():
		if child is StaticBody2D and child.has_meta("rect") and child.visible:
			var rect: Rect2 = child.get_meta("rect")
			var target := Rect2(child.position.x + rect.position.x, child.position.y + rect.position.y - 14, rect.size.x, minf(maxf(rect.size.y, 92), 150))
			var source := Rect2(15, 520, 510, 245) if bool(child.get_meta("fragile")) else Rect2(10, 185, 1070, 240)
			draw_texture_rect_region(kit, target, source)
	draw_rect(Rect2(370, 670, 330, 270), Color(0.005, 0.008, 0.012, 0.95))
	draw_rect(Rect2(1260, 420, 500, 250), Color(0.18, 0.7, 0.84, 0.09))
	for y in range(465, 645, 34): draw_line(Vector2(1300, y), Vector2(1720, y - 14), Color(0.52, 0.86, 0.92, 0.8), 3)
	draw_string(ThemeDB.fallback_font, Vector2(1410, 395), "HOLD FAST", HORIZONTAL_ALIGNMENT_CENTER, 200, 21, Color("c7edf0"))
	draw_string(ThemeDB.fallback_font, Vector2(3010, 625), "ONLY WEIGHT CAN OPEN THE WAY", HORIZONTAL_ALIGNMENT_CENTER, 380, 18, Color("edcf78"))
	if broken: draw_rect(Rect2(3130, 670, 185, 270), Color(0.005, 0.008, 0.012, 0.97))
