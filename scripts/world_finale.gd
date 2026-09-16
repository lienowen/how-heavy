extends "res://scripts/world_polished.gd"

var ending_layer: CanvasLayer

func complete_slice() -> void:
	if level_id < 24:
		super()
		return
	finished = true
	player.controls_enabled = false
	Game.complete_level(level_id, elapsed, exchanges, deaths)
	show_ending_choice()

func show_ending_choice() -> void:
	ending_layer = CanvasLayer.new()
	ending_layer.layer = 40
	add_child(ending_layer)
	var wash := ColorRect.new()
	wash.color = Color(0.006, 0.009, 0.014, 0.96)
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ending_layer.add_child(wash)
	var box := VBoxContainer.new()
	box.position = Vector2(260, 105)
	box.size = Vector2(760, 510)
	box.add_theme_constant_override("separation", 20)
	ending_layer.add_child(box)
	box.add_child(ending_label("THE LAST MEASURE", 16, Color("d7b85a")))
	box.add_child(ending_label("The hall has weighed every step.\nIt cannot weigh what you choose next.", 34, Color("f2eee5")))
	box.add_child(ending_label("One burden can remain here.\nOne can leave with you.", 21, Color("bfc8cb")))
	var release := ending_button("LEAVE THE WEIGHT BEHIND", choose_ending.bind("release"))
	box.add_child(release)
	box.add_child(ending_button("CARRY IT INTO THE WORLD", choose_ending.bind("carry")))
	release.grab_focus()

func choose_ending(choice: String) -> void:
	Game.progress.ending = choice
	Game.save_state()
	show_epilogue(choice)

func show_epilogue(choice: String) -> void:
	for child in ending_layer.get_children(): child.queue_free()
	var background_color := ColorRect.new()
	background_color.color = Color("11191c") if choice == "carry" else Color("d8d1bd")
	background_color.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ending_layer.add_child(background_color)
	var box := VBoxContainer.new()
	box.position = Vector2(245, 80)
	box.size = Vector2(790, 565)
	box.add_theme_constant_override("separation", 17)
	ending_layer.add_child(box)
	var ink := Color("edf1ed") if choice == "carry" else Color("20282a")
	var epilogue := "You leave lighter.\nThe doors stay open behind you." if choice == "release" else "You leave with its full weight.\nFor the first time, it is yours by choice."
	box.add_child(ending_label("THE WEIGHT WE CARRY", 44, ink))
	box.add_child(ending_label(epilogue, 27, ink))
	box.add_child(HSeparator.new())
	box.add_child(ending_label("Designed and developed by How Heavy Studio\n\nCreated with Godot Engine\n\nThank you for carrying this story with us.", 18, ink))
	box.add_child(ending_label("ENDING UNLOCKED  -  %s" % choice.to_upper(), 15, Color("d7b85a")))
	var return_button := ending_button("RETURN TO THE MEASURING HALL", finish_credits)
	box.add_child(return_button)
	return_button.grab_focus()

func finish_credits() -> void:
	return_to_menu.emit()
	queue_free()

func ending_label(text_value: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func ending_button(text_value: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(620, 58)
	button.add_theme_font_size_override("font_size", 18)
	button.pressed.connect(action)
	return button
