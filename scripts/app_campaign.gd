extends "res://scripts/app_english.gd"

const CampaignWorld = preload("res://scripts/world_campaign.gd")

func launch_game() -> void:
	launch_level(int(Game.current_level))

func launch_level(level_id: int) -> void:
	Game.current_level = clampi(level_id, 1, 24)
	if is_instance_valid(screen): screen.queue_free()
	screen = null
	world = CampaignWorld.new()
	world.return_to_menu.connect(show_title)
	world.next_level_requested.connect(launch_level)
	add_child(world)

func show_chapters() -> void:
	clear_view()
	add_backdrop()
	var veil := ColorRect.new()
	veil.color = Color(0.018, 0.023, 0.031, 0.94)
	veil.position = Vector2(105, 55)
	veil.size = Vector2(1070, 620)
	screen.add_child(veil)
	var title := make_label("THE MEASURING HALL", 38, Color("f2eee5"))
	title.position = Vector2(155, 92)
	screen.add_child(title)
	var subtitle := make_label("24 rooms. Four ways to understand what you carry.", 17, Color("bfc8cb"))
	subtitle.position = Vector2(157, 142)
	screen.add_child(subtitle)
	for index in range(Campaign.CHAPTERS.size()):
		var chapter: Dictionary = Campaign.CHAPTERS[index]
		var first_level: int = chapter.levels[0]
		var unlocked := int(Game.progress.unlocked_level) >= first_level
		var card := Button.new()
		card.position = Vector2(155 + (index % 2) * 500, 205 + (index / 2) * 175)
		card.size = Vector2(465, 145)
		card.text = "%s  %s\n%s\n%s" % [roman(index + 1), chapter.title, chapter.subtitle, chapter_progress(chapter)]
		card.add_theme_font_size_override("font_size", 18)
		card.disabled = not unlocked
		card.pressed.connect(show_levels.bind(index + 1))
		screen.add_child(card)
	var back := make_button("BACK", show_title)
	back.position = Vector2(155, 565)
	back.size = Vector2(210, 52)
	screen.add_child(back)

func show_levels(chapter_id: int) -> void:
	clear_view()
	add_backdrop()
	var chapter: Dictionary = Campaign.CHAPTERS[chapter_id - 1]
	var veil := ColorRect.new()
	veil.color = Color(0.018, 0.023, 0.031, 0.94)
	veil.position = Vector2(145, 52)
	veil.size = Vector2(990, 625)
	screen.add_child(veil)
	var heading := make_label("%s  %s" % [roman(chapter_id), chapter.title], 38, Color("f2eee5"))
	heading.position = Vector2(205, 92)
	screen.add_child(heading)
	for index in range(chapter.levels.size()):
		var level_id: int = chapter.levels[index]
		var info: Dictionary = Campaign.level(level_id)
		var button := Button.new()
		button.position = Vector2(205 + (index % 2) * 450, 170 + (index / 2) * 120)
		button.size = Vector2(410, 94)
		button.text = "%02d  %s\n%s" % [level_id, info.name, status_for(level_id)]
		button.add_theme_font_size_override("font_size", 17)
		button.disabled = level_id > int(Game.progress.unlocked_level)
		button.pressed.connect(launch_level.bind(level_id))
		screen.add_child(button)
	var back := make_button("BACK TO CHAPTERS", show_chapters)
	back.position = Vector2(205, 555)
	back.size = Vector2(280, 52)
	screen.add_child(back)

func chapter_progress(chapter: Dictionary) -> String:
	var done := 0
	for id in chapter.levels:
		if Game.progress.completed.has(str(id)): done += 1
	return "%d / 6 rooms complete" % done

func status_for(level_id: int) -> String:
	if Game.progress.completed.has(str(level_id)):
		return "COMPLETE  -  Best %.1fs" % float(Game.progress.best_times.get(str(level_id), 0.0))
	return "AVAILABLE" if level_id <= int(Game.progress.unlocked_level) else "LOCKED"

func roman(value: int) -> String:
	return ["I", "II", "III", "IV"][clampi(value - 1, 0, 3)]
