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

	# Keep the HUD light: gameplay should own most of the screen.
	var top := MarginContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 16
	top.offset_top = 12
	top.offset_right = -16
	top.offset_bottom = 68
	ui_root.add_child(top)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 10)
	top.add_child(top_row)

	var weight_card := PanelContainer.new()
	weight_card.custom_minimum_size = Vector2(205, 54)
	weight_card.add_theme_stylebox_override("panel", ProductionTheme.panel(Color(1, 1, 1, 0.93), Color("b9e7ef"), 1, 16))
	top_row.add_child(weight_card)
	var weight_row := HBoxContainer.new()
	weight_row.add_theme_constant_override("separation", 6)
	weight_card.add_child(weight_row)
	weight_dial = DialType.new()
	weight_dial.custom_minimum_size = Vector2(48, 48)
	weight_row.add_child(weight_dial)
	var weight_copy := VBoxContainer.new()
	weight_copy.alignment = BoxContainer.ALIGNMENT_CENTER
	weight_row.add_child(weight_copy)
	var eyebrow := Label.new()
	eyebrow.text = "WEIGHT"
	eyebrow.add_theme_font_size_override("font_size", 9)
	eyebrow.add_theme_color_override("font_color", ProductionTheme.MUTED)
	weight_copy.add_child(eyebrow)
	weight_label = Label.new()
	weight_label.add_theme_font_size_override("font_size", 17)
	weight_copy.add_child(weight_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(spacer)

	# Chapter/room is just a label now, not a giant card.
	chapter_label = Label.new()
	chapter_label.custom_minimum_size = Vector2(360, 42)
	chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chapter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chapter_label.add_theme_font_size_override("font_size", 15)
	chapter_label.add_theme_color_override("font_color", ProductionTheme.INK_2)
	top_row.add_child(chapter_label)

	var spacer_two := Control.new()
	spacer_two.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(spacer_two)

	stats_label = Label.new()
	stats_label.custom_minimum_size = Vector2(245, 42)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 11)
	stats_label.add_theme_color_override("font_color", ProductionTheme.MUTED)
	top_row.add_child(stats_label)

	var hint_panel := PanelContainer.new()
	hint_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hint_panel.position = Vector2(-230, -44)
	hint_panel.size = Vector2(460, 34)
	hint_panel.add_theme_stylebox_override("panel", ProductionTheme.panel(Color(1, 1, 1, 0.88), Color("d3eaf1"), 1, 12))
	ui_root.add_child(hint_panel)
	hint_label = Label.new()
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 11)
	hint_label.add_theme_color_override("font_color", ProductionTheme.INK_2)
	hint_label.text = base_hint()
	hint_panel.add_child(hint_label)

	result_panel = PanelContainer.new()
	result_panel.set_anchors_preset(Control.PRESET_CENTER)
	result_panel.position = Vector2(-230, -135)
	result_panel.size = Vector2(460, 270)
	result_panel.visible = false
	result_panel.add_theme_stylebox_override("panel", ProductionTheme.panel(Color(1, 1, 1, 0.98), Color("aee6f7"), 2, 22))
	ui_root.add_child(result_panel)
	result_label = Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 20)
	result_label.add_theme_color_override("font_color", ProductionTheme.INK)
	result_panel.add_child(result_label)

func update_weight(value: int) -> void:
	var quality := "LIGHT" if value <= 3 else ("HEAVY" if value >= 9 else "BALANCED")
	if is_instance_valid(weight_label):
		weight_label.text = "%d  %s" % [value, quality]
		weight_label.add_theme_color_override("font_color", ProductionTheme.CYAN if value <= 3 else (ProductionTheme.ORANGE if value >= 9 else ProductionTheme.GREEN))
	if is_instance_valid(weight_dial): weight_dial.weight = value

func build_first_session_tutorial() -> void:
	super()
	var panel := tutorial_label.get_parent() as PanelContainer
	panel.theme = ProductionTheme.build()
	panel.position = Vector2(420, 92)
	panel.size = Vector2(440, 44)
	panel.add_theme_stylebox_override("panel", ProductionTheme.panel(Color(1, 1, 1, 0.92), Color("bcecff"), 1, 14))
	tutorial_label.add_theme_font_size_override("font_size", 14)
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
