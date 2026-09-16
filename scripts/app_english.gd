extends "res://scripts/app_release.gd"

const EnglishWorld = preload("res://scripts/world_english.gd")
const MenuBackdropType = preload("res://scripts/menu_backdrop.gd")

func add_backdrop() -> void:
	var bg := MenuBackdropType.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(bg)

func show_title() -> void:
	clear_view()
	add_backdrop()

	var panel := PanelContainer.new()
	panel.position = Vector2(70, 68)
	panel.size = Vector2(500, 584)
	screen.add_child(panel)

	var content := VBoxContainer.new()
	content.position = Vector2(38, 34)
	content.size = Vector2(424, 510)
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)

	var kicker := make_label("FAST CHOICES • BIG CONSEQUENCES", 15, Color("2b8fd6"))
	content.add_child(kicker)

	var title := make_label("HOW\nHEAVY?", 64, Color("17324d"))
	title.custom_minimum_size.y = 154
	content.add_child(title)

	var pitch := make_label("Change your weight.\nPick the right route. Stay on the track.", 21, Color("45677f"))
	pitch.custom_minimum_size.y = 78
	content.add_child(pitch)

	var chips := HBoxContainer.new()
	chips.add_theme_constant_override("separation", 10)
	chips.add_child(make_chip("LIGHT", Color("31cfd2")))
	chips.add_child(make_chip("BALANCED", Color("55cf75")))
	chips.add_child(make_chip("HEAVY", Color("ff9a42")))
	content.add_child(chips)

	var play := make_button("PLAY NOW", launch_game)
	style_primary(play)
	play.custom_minimum_size = Vector2(424, 64)
	content.add_child(play)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var chapters := make_button("LEVELS", show_chapters)
	chapters.custom_minimum_size = Vector2(205, 54)
	var settings := make_button("SETTINGS", show_settings)
	settings.custom_minimum_size = Vector2(205, 54)
	row.add_child(chapters)
	row.add_child(settings)
	content.add_child(row)

	var tip := make_label("Tip: the lightest path is not always the safest.", 14, Color("6f8fa7"))
	content.add_child(tip)

	# Floating gameplay preview card on the right.
	var preview := PanelContainer.new()
	preview.position = Vector2(765, 100)
	preview.size = Vector2(390, 175)
	screen.add_child(preview)
	var preview_box := VBoxContainer.new()
	preview_box.position = Vector2(24, 18)
	preview_box.size = Vector2(342, 138)
	preview_box.add_theme_constant_override("separation", 8)
	preview.add_child(preview_box)
	preview_box.add_child(make_label("CURRENT WEIGHT", 14, Color("6f8fa7")))
	preview_box.add_child(make_label("42 kg", 48, Color("17324d")))
	var target := make_label("TARGET  25–45 kg   •   PERFECT", 17, Color("35a85a"))
	preview_box.add_child(target)

	var badge := PanelContainer.new()
	badge.position = Vector2(905, 310)
	badge.size = Vector2(210, 76)
	screen.add_child(badge)
	var badge_label := make_label("CHOOSE\nYOUR WEIGHT", 22, Color("17324d"))
	badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_child(badge_label)

func show_chapters() -> void:
	# Campaign layer replaces this with the full 24-level selector.
	clear_view()
	add_backdrop()
	var panel := PanelContainer.new()
	panel.position = Vector2(190, 85)
	panel.size = Vector2(900, 550)
	screen.add_child(panel)
	var box := VBoxContainer.new()
	box.position = Vector2(48, 38)
	box.size = Vector2(804, 470)
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)
	box.add_child(make_label("LEVELS", 46, Color("17324d")))
	box.add_child(make_label("Learn the rule. Make the choice. Feel the consequence.", 18, Color("6f8fa7")))
	box.add_child(make_button("START", launch_game))
	box.add_child(make_button("BACK", show_title))

func show_settings() -> void:
	clear_view()
	add_backdrop()

	var panel := PanelContainer.new()
	panel.position = Vector2(265, 80)
	panel.size = Vector2(750, 560)
	screen.add_child(panel)

	var box := VBoxContainer.new()
	box.position = Vector2(52, 38)
	box.size = Vector2(646, 478)
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)
	box.add_child(make_label("SETTINGS", 44, Color("17324d")))
	box.add_child(make_label("Keep the screen clean and the feedback strong.", 17, Color("6f8fa7")))

	for spec in [["Master Volume", "master_volume"], ["Music", "music_volume"], ["Sound Effects", "sfx_volume"]]:
		var row := HBoxContainer.new()
		var row_title := make_label(spec[0], 18, Color("244866"))
		row_title.custom_minimum_size.x = 180
		row.add_child(row_title)
		var slider := HSlider.new()
		slider.custom_minimum_size = Vector2(400, 42)
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value = float(Game.settings[spec[1]])
		slider.value_changed.connect(func(value): Game.settings[spec[1]] = value)
		slider.drag_ended.connect(func(_changed): Game.save_settings())
		row.add_child(slider)
		box.add_child(row)

	var contrast := CheckButton.new()
	contrast.text = "High-contrast interaction cues"
	contrast.button_pressed = bool(Game.settings.high_contrast)
	contrast.toggled.connect(func(value): Game.settings.high_contrast = value; Game.save_settings())
	box.add_child(contrast)

	var back := make_button("SAVE & BACK", show_title)
	style_primary(back)
	box.add_child(back)

func make_chip(text_value: String, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(128, 40)
	panel.add_theme_stylebox_override("panel", ProductionTheme.panel(Color(1, 1, 1, 0.92), Color(accent, 0.75), 2, 14))
	var label := make_label(text_value, 14, Color("17324d"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)
	return panel

func style_primary(button: Button) -> void:
	button.add_theme_stylebox_override("normal", ProductionTheme.button_box(Color("ff9a42"), Color("ffd1a5"), 20))
	button.add_theme_stylebox_override("hover", ProductionTheme.button_box(Color("ffad61"), Color.WHITE, 22))
	button.add_theme_stylebox_override("pressed", ProductionTheme.button_box(Color("ef8330"), Color.WHITE, 20))
	button.add_theme_stylebox_override("focus", ProductionTheme.button_box(Color("ff9a42"), Color.WHITE, 22))
	button.add_theme_font_size_override("font_size", 22)

func launch_game() -> void:
	if is_instance_valid(screen): screen.queue_free()
	screen = null
	world = EnglishWorld.new()
	world.return_to_menu.connect(show_title)
	add_child(world)
