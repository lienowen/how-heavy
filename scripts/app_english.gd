extends "res://scripts/app_release.gd"

const EnglishWorld = preload("res://scripts/world_english.gd")

func show_title() -> void:
	clear_view()
	add_backdrop()
	var panel := ColorRect.new()
	panel.color = Color(0.018, 0.023, 0.031, 0.94)
	panel.position = Vector2(76, 56)
	panel.size = Vector2(535, 610)
	screen.add_child(panel)
	var accent := ColorRect.new()
	accent.color = Color("d7b85a")
	accent.position = Vector2(76, 56)
	accent.size = Vector2(5, 610)
	screen.add_child(accent)
	var box := VBoxContainer.new()
	box.position = Vector2(132, 104)
	box.size = Vector2(425, 505)
	box.add_theme_constant_override("separation", 13)
	screen.add_child(box)
	box.add_child(make_label("A HANDCRAFTED PHYSICS PUZZLE", 13, Color("d7b85a")))
	box.add_child(make_label("THE WEIGHT\nWE CARRY", 52, Color("f2eee5")))
	var pitch := make_label("Trade your weight.\nChange what the world allows.", 20, Color("bfc8cb"))
	pitch.custom_minimum_size.y = 72
	box.add_child(pitch)
	box.add_child(HSeparator.new())
	box.add_child(make_button("BEGIN THE JOURNEY", launch_game))
	box.add_child(make_button("CHAPTERS", show_chapters))
	box.add_child(make_button("SETTINGS", show_settings))
	box.add_child(make_button("QUIT", func(): get_tree().quit()))

func show_chapters() -> void:
	clear_view()
	add_backdrop()
	var veil := ColorRect.new()
	veil.color = Color(0.018, 0.023, 0.031, 0.92)
	veil.position = Vector2(150, 68)
	veil.size = Vector2(980, 585)
	screen.add_child(veil)
	var box := VBoxContainer.new()
	box.position = Vector2(220, 112)
	box.size = Vector2(840, 500)
	box.add_theme_constant_override("separation", 16)
	screen.add_child(box)
	box.add_child(make_label("CHAPTERS", 42, Color("f2eee5")))
	box.add_child(make_label("Every burden opens one path—and closes another.", 18, Color("bfc8cb")))
	box.add_child(make_button("I  MEASURE  ·  Available", launch_game))
	for title in ["II  BALANCE  ·  Locked", "III  MOMENTUM  ·  Locked", "IV  COST  ·  Locked"]:
		var locked := make_button(title, func(): pass)
		locked.disabled = true
		box.add_child(locked)
	box.add_child(make_button("BACK", show_title))

func show_settings() -> void:
	clear_view()
	add_backdrop()
	var veil := ColorRect.new()
	veil.color = Color(0.018, 0.023, 0.031, 0.94)
	veil.position = Vector2(270, 70)
	veil.size = Vector2(740, 580)
	screen.add_child(veil)
	var box := VBoxContainer.new()
	box.position = Vector2(330, 112)
	box.size = Vector2(620, 500)
	box.add_theme_constant_override("separation", 18)
	screen.add_child(box)
	box.add_child(make_label("SETTINGS", 42, Color("f2eee5")))
	for spec in [["Master Volume", "master_volume"], ["Music", "music_volume"], ["Sound Effects", "sfx_volume"]]:
		var row := HBoxContainer.new()
		var title := make_label(spec[0], 18, Color("e8e4db"))
		title.custom_minimum_size.x = 170
		row.add_child(title)
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
	box.add_child(make_button("SAVE & BACK", show_title))

func launch_game() -> void:
	if is_instance_valid(screen): screen.queue_free()
	screen = null
	world = EnglishWorld.new()
	world.return_to_menu.connect(show_title)
	add_child(world)
