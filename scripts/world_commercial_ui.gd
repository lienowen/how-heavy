extends "res://scripts/world_production_art_fixed.gd"

const DialType = preload("res://scripts/weight_dial.gd")
var ui_root: Control
var weight_dial: WeightDial

func build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 12
	add_child(layer)
	ui_root = Control.new()
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.theme = ProductionTheme.build()
	layer.add_child(ui_root)

	var top := MarginContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 18
	top.offset_top = 14
	top.offset_right = -18
	top.offset_bottom = 94
	ui_root.add_child(top)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 12)
	top.add_child(top_row)

	# Weight is the primary information in this game, so it gets the strongest card.
	var weight_card := PanelContainer.new()
	weight_card.custom_minimum_size = Vector2(255, 76)
	weight_card.add_theme_stylebox_override("panel", ProductionTheme.panel(Color(1, 1, 1, 0.96), Color("b9eef0"), 2, 20))
	top_row.add_child(weight_card)
	var weight_row := HBoxContainer.new()
	weight_row.add_theme_constant_override("separation", 8)
	weight_card.add_child(weight_row)
	weight_dial = DialType.new()
	weight_row.add_child(weight_dial)
	var weight_copy := VBoxContainer.new()
	weight_copy.alignment = BoxContainer.ALIGNMENT_CENTER
	weight_row.add_child(weight_copy)
	var eyebrow := Label.new()
	eyebrow.text = "WEIGHT"
	eyebrow.add_theme_font_size_override("font_size", 11)
	eyebrow.add_theme_color_override("font_color", ProductionTheme.MUTED)
	weight_copy.add_child(eyebrow)
	weight_label = Label.new()
	weight_label.add_theme_font_size_override("font_size", 22)
	weight_label.add_theme_color_override("font_color", ProductionTheme.INK)
	weight_copy.add_child(weight_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(spacer)

	var room_card := PanelContainer.new()
	room_card.custom_minimum_size = Vector2(280, 64)
	room_card.add_theme_stylebox_override("panel", ProductionTheme.panel(Color(1, 1, 1, 0.94), Color("cfeeff"), 2, 18))
	top_row.add_child(room_card)
	chapter_label = Label.new()
	chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chapter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chapter_label.add_theme_font_size_override("font_size", 17)
	chapter_label.add_theme_color_override("font_color", ProductionTheme.INK_2)
	room_card.add_child(chapter_label)

	var spacer_two := Control.new()
	spacer_two.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(spacer_two)

	var stats_card := PanelContainer.new()
	stats_card.custom_minimum_size = Vector2(245, 64)
	stats_card.add_theme_stylebox_override("panel", ProductionTheme.panel(Color(1, 1, 1, 0.90), Color("d9edf6"), 1, 18))
	top_row.add_child(stats_card)
	stats_label = Label.new()
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 13)
	stats_label.add_theme_color_override("font_color", ProductionTheme.MUTED)
	stats_card.add_child(stats_label)

	# Context hint stays low and compact so it never fights the playfield.
	var hint_panel := PanelContainer.new()
	hint_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hint_panel.position = Vector2(-285, -62)
	hint_panel.size = Vector2(570, 44)
	hint_panel.add_theme_stylebox_override("panel", ProductionTheme.panel(Color(1, 1, 1, 0.92), Color("d3eef8"), 1, 16))
	ui_root.add_child(hint_panel)
	hint_label = Label.new()
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 13)
	hint_label.add_theme_color_override("font_color", ProductionTheme.INK_2)
	hint_label.text = base_hint()
	hint_panel.add_child(hint_label)

	result_panel = PanelContainer.new()
	result_panel.set_anchors_preset(Control.PRESET_CENTER)
	result_panel.position = Vector2(-250, -150)
	result_panel.size = Vector2(500, 300)
	result_panel.visible = false
	result_panel.add_theme_stylebox_override("panel", ProductionTheme.panel(Color(1, 1, 1, 0.98), Color("aee6f7"), 3, 24))
	ui_root.add_child(result_panel)
	result_label = Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 22)
	result_label.add_theme_color_override("font_color", ProductionTheme.INK)
	result_panel.add_child(result_label)

func update_weight(value: int) -> void:
	var quality := "LIGHT" if value <= 3 else ("HEAVY" if value >= 9 else "BALANCED")
	if is_instance_valid(weight_label):
		weight_label.text = "%d  •  %s" % [value, quality]
		weight_label.add_theme_color_override("font_color", ProductionTheme.CYAN if value <= 3 else (ProductionTheme.ORANGE if value >= 9 else ProductionTheme.GREEN))
	if is_instance_valid(weight_dial): weight_dial.weight = value

func build_first_session_tutorial() -> void:
	super()
	var panel := tutorial_label.get_parent() as PanelContainer
	panel.theme = ProductionTheme.build()
	panel.position = Vector2(385, 122)
	panel.add_theme_stylebox_override("panel", ProductionTheme.panel(Color(1, 1, 1, 0.96), Color("bcecff"), 2, 18))
	tutorial_label.add_theme_color_override("font_color", ProductionTheme.INK)
	tutorial_label.add_theme_color_override("font_shadow_color", Color(1, 1, 1, 0.0))

func complete_slice() -> void:
	super()
	if is_instance_valid(next_button):
		next_button.theme = ProductionTheme.build()
		next_button.position = Vector2(465, 500)
		next_button.add_theme_stylebox_override("normal", ProductionTheme.button_box(ProductionTheme.ORANGE, Color("ffd2a8"), 20))
		next_button.add_theme_stylebox_override("hover", ProductionTheme.button_box(Color("ffad61"), Color.WHITE, 22))

func build_touch_controls() -> void:
	super()
	for node in touch_layer.find_children("*", "Button", true, false):
		node.theme = ProductionTheme.build()
		node.modulate = Color(1, 1, 1, 0.94)
