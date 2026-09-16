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
	top.offset_top = 16
	top.offset_right = -18
	top.offset_bottom = 102
	ui_root.add_child(top)
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 16)
	top.add_child(top_row)

	var weight_card := PanelContainer.new()
	weight_card.custom_minimum_size = Vector2(275, 82)
	top_row.add_child(weight_card)
	var weight_row := HBoxContainer.new()
	weight_row.add_theme_constant_override("separation", 10)
	weight_card.add_child(weight_row)
	weight_dial = DialType.new()
	weight_row.add_child(weight_dial)
	var weight_copy := VBoxContainer.new()
	weight_copy.alignment = BoxContainer.ALIGNMENT_CENTER
	weight_row.add_child(weight_copy)
	var eyebrow := Label.new()
	eyebrow.text = "CURRENT LOAD"
	eyebrow.add_theme_font_size_override("font_size", 11)
	eyebrow.add_theme_color_override("font_color", ProductionTheme.BRASS_BRIGHT)
	weight_copy.add_child(eyebrow)
	weight_label = Label.new()
	weight_label.add_theme_font_size_override("font_size", 20)
	weight_copy.add_child(weight_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(spacer)
	var room_card := PanelContainer.new()
	room_card.custom_minimum_size = Vector2(300, 72)
	top_row.add_child(room_card)
	chapter_label = Label.new()
	chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chapter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chapter_label.add_theme_font_size_override("font_size", 18)
	chapter_label.add_theme_color_override("font_color", ProductionTheme.BRASS_BRIGHT)
	room_card.add_child(chapter_label)
	var spacer_two := Control.new()
	spacer_two.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(spacer_two)
	var stats_card := PanelContainer.new()
	stats_card.custom_minimum_size = Vector2(275, 72)
	top_row.add_child(stats_card)
	stats_label = Label.new()
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 13)
	stats_label.add_theme_color_override("font_color", ProductionTheme.MUTED)
	stats_card.add_child(stats_label)

	var hint_panel := PanelContainer.new()
	hint_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hint_panel.position = Vector2(-300, -66)
	hint_panel.size = Vector2(600, 48)
	ui_root.add_child(hint_panel)
	hint_label = Label.new()
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 14)
	hint_label.text = base_hint()
	hint_panel.add_child(hint_label)

	result_panel = PanelContainer.new()
	result_panel.set_anchors_preset(Control.PRESET_CENTER)
	result_panel.position = Vector2(-250, -150)
	result_panel.size = Vector2(500, 300)
	result_panel.visible = false
	ui_root.add_child(result_panel)
	result_label = Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 21)
	result_panel.add_child(result_label)

func update_weight(value: int) -> void:
	var quality := "LIGHT" if value <= 3 else ("HEAVY" if value >= 9 else "BALANCED")
	if is_instance_valid(weight_label): weight_label.text = "%s  /  %d" % [quality, value]
	if is_instance_valid(weight_dial): weight_dial.weight = value

func build_first_session_tutorial() -> void:
	super()
	var panel := tutorial_label.get_parent() as PanelContainer
	panel.theme = ProductionTheme.build()
	panel.position = Vector2(385, 122)
	tutorial_label.add_theme_color_override("font_color", ProductionTheme.IVORY)
	tutorial_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))

func complete_slice() -> void:
	super()
	if is_instance_valid(next_button):
		next_button.theme = ProductionTheme.build()
		next_button.position = Vector2(465, 500)
		next_button.add_theme_color_override("font_color", ProductionTheme.BRASS_BRIGHT)

func build_touch_controls() -> void:
	super()
	for node in touch_layer.find_children("*", "Button", true, false):
		node.theme = ProductionTheme.build()
		node.modulate = Color(1, 1, 1, 0.88)

