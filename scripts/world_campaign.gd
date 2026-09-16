extends "res://scripts/world_english.gd"

signal next_level_requested(level_id: int)
var level_id := 1
var level_info: Dictionary
var needs_break := false

func _ready() -> void:
	level_id = clampi(int(Game.current_level), 1, 24)
	level_info = Campaign.level(level_id)
	super()

func build_level() -> void:
	var chapter := Campaign.chapter_for_level(level_id)
	var variant := (level_id - 1) % 6
	needs_break = variant >= 4 or chapter == 4
	make_platform(Rect2(0, 670, 390, 150))
	make_stone(Vector2(245, 625), 2 if variant % 2 == 0 else 10)
	if variant == 0:
		make_platform(Rect2(650, 670, 570, 150))
	elif variant == 1:
		make_platform(Rect2(720, 590, 260, 120)); make_platform(Rect2(1020, 670, 200, 150))
	else:
		make_platform(Rect2(610, 670, 260, 150)); make_platform(Rect2(940, 565, 280, 105))
	make_stone(Vector2(1080, 520 if variant >= 2 else 625), 10)
	make_platform(Rect2(1220, 670, 620, 150))
	if chapter >= 2:
		make_stone(Vector2(1450, 625), 6 if variant % 2 == 0 else 2)
	make_platform(Rect2(1840, 670, 430, 150))
	make_stone(Vector2(2070, 625), 2)
	if chapter >= 3:
		make_platform(Rect2(2350, 570, 245, 90)); make_platform(Rect2(2660, 475, 245, 90)); make_platform(Rect2(2960, 570, 190, 90))
	else:
		make_platform(Rect2(2270, 670, 390, 150)); make_platform(Rect2(2730, 570, 400, 100))
	make_stone(Vector2(3010, 520), 10)
	fragile = make_platform(Rect2(3130, 670, 185, 32), needs_break)
	make_platform(Rect2(3315, 820 if needs_break else 670, 260, 120))

func _process(delta: float) -> void:
	if not finished and not respawning and not get_tree().paused: elapsed += delta
	stats_label.text = "ROOM %02d / 24     %.1fs  -  %d trades  -  %d falls" % [level_id, elapsed, exchanges, deaths]
	if not is_instance_valid(player): return
	var chapter := Campaign.chapter_for_level(level_id)
	player.wind_force = (650.0 + chapter * 100.0) if player.position.x > 1260 and player.position.x < 1780 and (level_id % 3 != 1) else 0.0
	update_interaction()
	update_checkpoint()
	chapter_label.text = "%s  /  %s" % [Campaign.CHAPTERS[chapter - 1].title, level_info.name.to_upper()]
	if player.position.x > 3450 and (not needs_break or broken) and not finished: complete_slice()

func complete_slice() -> void:
	finished = true
	player.controls_enabled = false
	Game.complete_level(level_id, elapsed, exchanges, deaths)
	var final_room := level_id == 24
	result_label.text = ("THE HALL NO LONGER MEASURES YOU.\n\nYou chose what the world will carry.\n\nESC  RETURN TO TITLE" if final_room else "ROOM COMPLETE\n\n%s\n\n%.1f seconds  -  %d trades  -  %d falls\n\nENTER  NEXT ROOM     R  RETRY     ESC  CHAPTERS" % [level_info.lesson, elapsed, exchanges, deaths])
	result_panel.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if finished and event.is_action_pressed("ui_accept") and level_id < 24:
		next_level_requested.emit(level_id + 1)
		queue_free()
		return
	super(event)
