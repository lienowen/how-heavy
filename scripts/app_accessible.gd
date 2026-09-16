extends "res://scripts/app_mechanics.gd"

const AudioWorld = preload("res://scripts/world_audio.gd")

func launch_game() -> void:
	launch_level(int(Game.current_level))

func launch_level(level_id: int) -> void:
	Game.current_level = clampi(level_id, 1, 24)
	if is_instance_valid(screen): screen.queue_free()
	screen = null
	world = AudioWorld.new()
	world.return_to_menu.connect(show_title)
	world.next_level_requested.connect(launch_level)
	add_child(world)

func show_settings() -> void:
	clear_view()
	add_backdrop()
	var veil := ColorRect.new()
	veil.color = Color(0.018, 0.023, 0.031, 0.96)
	veil.position = Vector2(205, 38)
	veil.size = Vector2(870, 650)
	screen.add_child(veil)
	var heading := make_label("SETTINGS & ACCESSIBILITY", 36, Color("f2eee5"))
	heading.position = Vector2(265, 70)
	screen.add_child(heading)
	var left := VBoxContainer.new()
	left.position = Vector2(265, 135)
	left.size = Vector2(365, 480)
	left.add_theme_constant_override("separation", 13)
	screen.add_child(left)
	left.add_child(make_label("AUDIO", 15, Color("d7b85a")))
	for spec in [["Master", "master_volume"], ["Music", "music_volume"], ["Sound Effects", "sfx_volume"]]: left.add_child(volume_row(spec[0], spec[1]))
	left.add_child(make_label("DISPLAY", 15, Color("d7b85a")))
	left.add_child(toggle("Fullscreen", "fullscreen"))
	left.add_child(toggle("Disable screen shake", "screen_shake", true))
	left.add_child(toggle("Reduce flashes", "reduced_flashes"))
	var right := VBoxContainer.new()
	right.position = Vector2(665, 135)
	right.size = Vector2(350, 480)
	right.add_theme_constant_override("separation", 13)
	screen.add_child(right)
	right.add_child(make_label("ACCESSIBILITY", 15, Color("d7b85a")))
	right.add_child(toggle("High-contrast interaction cues", "high_contrast"))
	right.add_child(toggle("Assist mode (longer trade range)", "assist_mode"))
	var text_title := make_label("Text size", 17, Color("e8e4db"))
	right.add_child(text_title)
	var text_slider := HSlider.new()
	text_slider.min_value = 0.9
	text_slider.max_value = 1.4
	text_slider.step = 0.1
	text_slider.value = float(Game.settings.text_scale)
	text_slider.value_changed.connect(func(value): Game.settings.text_scale = value)
	text_slider.drag_ended.connect(func(_changed): Game.save_settings())
	right.add_child(text_slider)
	right.add_child(make_label("CONTROLS", 15, Color("d7b85a")))
	right.add_child(make_label("Move   A/D or Left Stick\nJump   Space or A\nTrade  E or X\nPause  Esc or Menu", 16, Color("c7d0d1")))
	var back := make_button("SAVE & BACK", func(): Game.save_settings(); show_title())
	back.position = Vector2(665, 570)
	back.size = Vector2(300, 52)
	screen.add_child(back)

func volume_row(title_text: String, key: String) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_child(make_label(title_text, 16, Color("e8e4db")))
	var slider := HSlider.new()
	slider.custom_minimum_size = Vector2(340, 28)
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = float(Game.settings[key])
	slider.value_changed.connect(func(value): Game.settings[key] = value)
	slider.drag_ended.connect(func(_changed): Game.save_settings())
	box.add_child(slider)
	return box

func toggle(title_text: String, key: String, invert := false) -> CheckButton:
	var result := CheckButton.new()
	result.text = title_text
	result.button_pressed = not bool(Game.settings[key]) if invert else bool(Game.settings[key])
	result.toggled.connect(func(value): Game.settings[key] = not value if invert else value; Game.save_settings())
	return result
