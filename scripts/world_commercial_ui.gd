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

	# One compact status chip only. Gameplay owns the screen.
	var weight_card := PanelContainer.new()
	weight_card.position = Vector2(18, 16)
	weight_card.size = Vector2(170, 48)
	weight_card.add_theme_stylebox_override("panel", ProductionTheme.panel(Color(0.06,0.14,0.20,0.90), Color(1,1,1,0.14), 1, 14))
	ui_root.add_child(weight_card)
	var weight_row := HBoxContainer.new()
	weight_row.add_theme_constant_override("separation", 6)
	weight_card.add_child(weight_row)
	weight_dial = DialType.new()
	weight_dial.custom_minimum_size = Vector2(42,42)
	weight_row.add_child(weight_dial)
	var copy := VBoxContainer.new()
	copy.alignment = BoxContainer.ALIGNMENT_CENTER
	weight_row.add_child(copy)
	var eyebrow := Label.new()
	eyebrow.text = "WEIGHT"
	eyebrow.add_theme_font_size_override("font_size", 8)
	eyebrow.add_theme_color_override("font_color", Color(0.78,0.88,0.94,0.84))
	copy.add_child(eyebrow)
	weight_label = Label.new()
	weight_label.add_theme_font_size_override("font_size", 16)
	weight_label.add_theme_color_override("font_color", Color.WHITE)
	copy.add_child(weight_label)

	chapter_label = Label.new()
	chapter_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	chapter_label.position = Vector2(-170, 18)
	chapter_label.size = Vector2(340, 30)
	chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chapter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chapter_label.add_theme_font_size_override("font_size", 13)
	chapter_label.add_theme_color_override("font_color", Color(0.10,0.24,0.32,0.72))
	ui_root.add_child(chapter_label)

	# Keep stats available but visually secondary.
	stats_label = Label.new()
	stats_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	stats_label.position = Vector2(-228, 18)
	stats_label.size = Vector2(210, 26)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stats_label.add_theme_font_size_override("font_size", 9)
	stats_label.add_theme_color_override("font_color", Color(0.12,0.28,0.36,0.48))
	ui_root.add_child(stats_label)

	var hint_panel := PanelContainer.new()
	hint_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hint_panel.position = Vector2(-185,-38)
	hint_panel.size = Vector2(370,28)
	hint_panel.add_theme_stylebox_override("panel", ProductionTheme.panel(Color(0.05,0.13,0.18,0.72), Color(1,1,1,0.10), 1, 11))
	ui_root.add_child(hint_panel)
	hint_label = Label.new()
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 10)
	hint_label.add_theme_color_override("font_color", Color(1,1,1,0.90))
	hint_label.text = base_hint()
	hint_panel.add_child(hint_label)

	result_panel = PanelContainer.new()
	result_panel.set_anchors_preset(Control.PRESET_CENTER)
	result_panel.position = Vector2(-220,-130)
	result_panel.size = Vector2(440,260)
	result_panel.visible = false
	result_panel.add_theme_stylebox_override("panel", ProductionTheme.panel(Color(1,1,1,0.98), Color("aee6f7"), 2, 22))
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
		weight_label.add_theme_color_override("font_color", ProductionTheme.CYAN if value <= 3 else (ProductionTheme.ORANGE if value >= 9 else Color.WHITE))
	if is_instance_valid(weight_dial): weight_dial.weight = value

func build_first_session_tutorial() -> void:
	super()
	var panel := tutorial_label.get_parent() as PanelContainer
	panel.theme = ProductionTheme.build()
	panel.position = Vector2(455,72)
	panel.size = Vector2(370,34)
	panel.add_theme_stylebox_override("panel", ProductionTheme.panel(Color(0.05,0.13,0.18,0.72), Color(1,1,1,0.10), 1, 12))
	tutorial_label.add_theme_font_size_override("font_size", 11)
	tutorial_label.add_theme_color_override("font_color", Color.WHITE)
	tutorial_label.add_theme_color_override("font_shadow_color", Color(0,0,0,0))

func complete_slice() -> void:
	super()
	if is_instance_valid(next_button):
		next_button.theme = ProductionTheme.build()
		next_button.position = Vector2(465,500)
		next_button.add_theme_stylebox_override("normal", ProductionTheme.button_box(ProductionTheme.ORANGE, Color("ffd2a8"), 20))
		next_button.add_theme_stylebox_override("hover", ProductionTheme.button_box(Color("ffad61"), Color.WHITE, 22))

func build_touch_controls() -> void:
	super()
	for node in touch_layer.find_children("*", "Button", true, false):
		node.theme = ProductionTheme.build()
		node.modulate = Color(1,1,1,0.90)
