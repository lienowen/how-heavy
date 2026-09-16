extends "res://scripts/app_english.gd"

const CampaignWorld = preload("res://scripts/world_campaign.gd")
const CHAPTER_COLORS := [Color("45c6ff"), Color("4bd7c1"), Color("8b9dff"), Color("ff9a62")]

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

	var panel := PanelContainer.new()
	panel.position = Vector2(100, 62)
	panel.size = Vector2(1080, 596)
	screen.add_child(panel)

	var title := make_label("CHOOSE A CHAPTER", 42, Color("17324d"))
	title.position = Vector2(148, 94)
	screen.add_child(title)
	var subtitle := make_label("24 short rooms • one clear rule per challenge", 17, Color("6f8fa7"))
	subtitle.position = Vector2(150, 145)
	screen.add_child(subtitle)

	for index in range(Campaign.CHAPTERS.size()):
		var chapter: Dictionary = Campaign.CHAPTERS[index]
		var first_level: int = chapter.levels[0]
		var unlocked := int(Game.progress.unlocked_level) >= first_level
		var card := Button.new()
		card.position = Vector2(145 + (index % 2) * 500, 205 + (index / 2) * 166)
		card.size = Vector2(465, 136)
		card.text = "%s  %s\n%s\n%s" % [roman(index + 1), chapter.title, chapter.subtitle, chapter_progress(chapter)]
		card.add_theme_font_size_override("font_size", 17)
		card.disabled = not unlocked
		if unlocked:
			var accent: Color = CHAPTER_COLORS[index]
			card.add_theme_stylebox_override("normal", ProductionTheme.button_box(Color(accent, 0.90), Color(accent).lightened(0.25), 20))
			card.add_theme_stylebox_override("hover", ProductionTheme.button_box(Color(accent).lightened(0.08), Color.WHITE, 22))
		card.pressed.connect(show_levels.bind(index + 1))
		screen.add_child(card)

	var back := make_button("BACK", show_title)
	back.position = Vector2(145, 555)
	back.size = Vector2(210, 54)
	screen.add_child(back)

func show_levels(chapter_id: int) -> void:
	clear_view()
	add_backdrop()

	var chapter: Dictionary = Campaign.CHAPTERS[chapter_id - 1]
	var accent: Color = CHAPTER_COLORS[chapter_id - 1]
	var panel := PanelContainer.new()
	panel.position = Vector2(115, 55)
	panel.size = Vector2(1050, 610)
	screen.add_child(panel)

	var heading := make_label("%s  %s" % [roman(chapter_id), chapter.title], 40, Color("17324d"))
	heading.position = Vector2(165, 88)
	screen.add_child(heading)
	var subtitle := make_label(chapter.subtitle, 17, Color("6f8fa7"))
	subtitle.position = Vector2(168, 136)
	screen.add_child(subtitle)

	for index in range(chapter.levels.size()):
		var level_id: int = chapter.levels[index]
		var info: Dictionary = Campaign.level(level_id)
		var button := Button.new()
		button.position = Vector2(165 + (index % 2) * 468, 190 + (index / 2) * 116)
		button.size = Vector2(430, 92)
		button.text = "%02d   %s\n%s" % [level_id, info.name, status_for(level_id)]
		button.add_theme_font_size_override("font_size", 16)
		button.disabled = level_id > int(Game.progress.unlocked_level)
		if not button.disabled:
			button.add_theme_stylebox_override("normal", ProductionTheme.button_box(Color(accent, 0.92), Color(accent).lightened(0.24), 18))
			button.add_theme_stylebox_override("hover", ProductionTheme.button_box(Color(accent).lightened(0.08), Color.WHITE, 20))
		button.pressed.connect(launch_level.bind(level_id))
		screen.add_child(button)

	var back := make_button("BACK TO CHAPTERS", show_chapters)
	back.position = Vector2(165, 555)
	back.size = Vector2(280, 54)
	screen.add_child(back)

func chapter_progress(chapter: Dictionary) -> String:
	var done := 0
	for id in chapter.levels:
		if Game.progress.completed.has(str(id)): done += 1
	return "%d / 6 rooms complete" % done

func status_for(level_id: int) -> String:
	if Game.progress.completed.has(str(level_id)):
		return "COMPLETE  •  Best %.1fs" % float(Game.progress.best_times.get(str(level_id), 0.0))
	return "AVAILABLE" if level_id <= int(Game.progress.unlocked_level) else "LOCKED"

func roman(value: int) -> String:
	return ["I", "II", "III", "IV"][clampi(value - 1, 0, 3)]
