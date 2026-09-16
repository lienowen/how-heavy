extends Node

const World = preload("res://scripts/world.gd")
var screen: Control
var world: Node2D

func _ready() -> void:
	show_title()

func clear_view() -> void:
	if is_instance_valid(world):
		world.queue_free()
		world = null
	if is_instance_valid(screen):
		screen.queue_free()
	screen = Control.new()
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen)

func add_backdrop() -> void:
	var bg := TextureRect.new()
	bg.texture = load("res://keyvisual-v1.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(bg)
	var wash := ColorRect.new()
	wash.color = Color(0.025, 0.03, 0.04, 0.7)
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(wash)

func show_title() -> void:
	clear_view()
	add_backdrop()
	var panel := ColorRect.new()
	panel.color = Color(0.025, 0.03, 0.04, 0.92)
	panel.position = Vector2(86, 70)
	panel.size = Vector2(500, 580)
	screen.add_child(panel)
	var box := VBoxContainer.new()
	box.position = Vector2(138, 120)
	box.size = Vector2(395, 470)
	box.add_theme_constant_override("separation", 16)
	screen.add_child(box)
	box.add_child(make_label("A PUZZLE ABOUT WHAT WE CARRY", 14, Color("d9b94f")))
	box.add_child(make_label("一个人\n多重", 60, Color.WHITE))
	box.add_child(HSeparator.new())
	box.add_child(make_button("开始旅程", launch_game))
	box.add_child(make_button("章节选择", show_chapters))
	box.add_child(make_button("设置", show_settings))
	box.add_child(make_button("退出", func(): get_tree().quit()))

func show_chapters() -> void:
	clear_view()
	add_backdrop()
	var box := VBoxContainer.new()
	box.position = Vector2(250, 110)
	box.size = Vector2(780, 500)
	box.add_theme_constant_override("separation", 18)
	screen.add_child(box)
	box.add_child(make_label("章节选择", 42, Color.WHITE))
	box.add_child(make_button("第一章 · 越过  —  可游玩", launch_game))
	for title in ["第二章 · 逆风  —  开发中", "第三章 · 坠落  —  开发中", "第四章 · 代价  —  开发中"]:
		var locked := make_button(title, func(): pass)
		locked.disabled = true
		box.add_child(locked)
	box.add_child(make_button("返回", show_title))

func show_settings() -> void:
	clear_view()
	add_backdrop()
	var box := VBoxContainer.new()
	box.position = Vector2(330, 115)
	box.size = Vector2(620, 480)
	box.add_theme_constant_override("separation", 20)
	screen.add_child(box)
	box.add_child(make_label("设置", 42, Color.WHITE))
	for spec in [["主音量", "master_volume"], ["音乐", "music_volume"], ["音效", "sfx_volume"]]:
		var row := HBoxContainer.new()
		var name := make_label(spec[0], 18, Color.WHITE)
		name.custom_minimum_size.x = 140
		row.add_child(name)
		var slider := HSlider.new()
		slider.custom_minimum_size = Vector2(420, 42)
		slider.max_value = 1.0
		slider.step = 0.05
		slider.value = float(Game.settings[spec[1]])
		slider.value_changed.connect(func(value): Game.settings[spec[1]] = value)
		slider.drag_ended.connect(func(_changed): Game.save_settings())
		row.add_child(slider)
		box.add_child(row)
	box.add_child(make_button("保存并返回", show_title))

func launch_game() -> void:
	if is_instance_valid(screen):
		screen.queue_free()
		screen = null
	world = World.new()
	world.return_to_menu.connect(show_title)
	add_child(world)

func make_label(text_value: String, size: int, color: Color) -> Label:
	var result := Label.new()
	result.text = text_value
	result.add_theme_font_size_override("font_size", size)
	result.add_theme_color_override("font_color", color)
	return result

func make_button(text_value: String, action: Callable) -> Button:
	var result := Button.new()
	result.text = text_value
	result.custom_minimum_size = Vector2(390, 56)
	result.add_theme_font_size_override("font_size", 20)
	result.pressed.connect(action)
	return result
