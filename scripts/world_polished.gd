extends "res://scripts/world_audio.gd"

const AnimatedPlayerType = preload("res://scripts/player_animated.gd")
var pause_layer: CanvasLayer

func _ready() -> void:
	super()
	build_pause_menu()

func spawn_player() -> void:
	player = AnimatedPlayerType.new()
	player.position = START
	add_child(player)
	player.weight_changed.connect(update_weight)
	player.exchanged.connect(func(): exchanges += 1)
	player.fell_out.connect(on_fell)
	player.heavy_impact.connect(on_impact)
	var camera := Camera2D.new()
	camera.position = Vector2(0, -250)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 6
	camera.limit_left = 0
	camera.limit_right = 3550
	camera.limit_top = 0
	camera.limit_bottom = 940
	player.add_child(camera)
	update_weight(player.weight)

func build_pause_menu() -> void:
	pause_layer = CanvasLayer.new()
	pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_layer.visible = false
	pause_layer.layer = 30
	add_child(pause_layer)
	var wash := ColorRect.new()
	wash.color = Color(0.005, 0.008, 0.012, 0.86)
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_layer.add_child(wash)
	var panel := ColorRect.new()
	panel.color = Color(0.03, 0.04, 0.05, 0.98)
	panel.position = Vector2(430, 145)
	panel.size = Vector2(420, 430)
	pause_layer.add_child(panel)
	var box := VBoxContainer.new()
	box.position = Vector2(475, 190)
	box.size = Vector2(330, 340)
	box.add_theme_constant_override("separation", 18)
	pause_layer.add_child(box)
	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	box.add_child(title)
	var room := Label.new()
	room.text = "ROOM %02d  -  %s" % [level_id, level_info.name.to_upper()]
	room.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	room.add_theme_color_override("font_color", Color("bfc8cb"))
	box.add_child(room)
	box.add_child(pause_button("RESUME", resume_game))
	box.add_child(pause_button("RESTART ROOM", restart_room))
	box.add_child(pause_button("RETURN TO CHAPTERS", return_to_chapters))

func pause_button(text_value: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(330, 56)
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(action)
	return button

func set_paused(value: bool) -> void:
	get_tree().paused = value
	pause_layer.visible = value
	if value:
		for node in pause_layer.find_children("*", "Button", true, false):
			node.grab_focus()
			break

func resume_game() -> void:
	set_paused(false)

func restart_room() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func return_to_chapters() -> void:
	get_tree().paused = false
	return_to_menu.emit()
	queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		if finished:
			return_to_chapters()
		else:
			set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("restart"):
		restart_room()
		return
	if finished and event.is_action_pressed("ui_accept") and level_id < 24:
		next_level_requested.emit(level_id + 1)
		queue_free()
