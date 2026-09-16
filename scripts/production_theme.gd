class_name ProductionTheme
extends RefCounted

const INK := Color("10191d")
const INK_2 := Color("18262c")
const BRASS := Color("c9a85b")
const BRASS_BRIGHT := Color("e4ca78")
const IVORY := Color("f2eee5")
const MUTED := Color("aebbc0")
const CYAN := Color("75c8cc")

static func panel(fill := Color(0.035, 0.055, 0.063, 0.94), border := BRASS, width := 1) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(width)
	box.corner_radius_top_left = 3
	box.corner_radius_top_right = 3
	box.corner_radius_bottom_left = 3
	box.corner_radius_bottom_right = 3
	box.content_margin_left = 18
	box.content_margin_right = 18
	box.content_margin_top = 12
	box.content_margin_bottom = 12
	return box

static func build() -> Theme:
	var theme := Theme.new()
	theme.set_color("font_color", "Label", IVORY)
	theme.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.7))
	theme.set_constant("shadow_offset_x", "Label", 1)
	theme.set_constant("shadow_offset_y", "Label", 2)
	theme.set_font_size("font_size", "Label", 16)
	theme.set_stylebox("panel", "PanelContainer", panel())
	theme.set_color("font_color", "Button", IVORY)
	theme.set_color("font_hover_color", "Button", Color.WHITE)
	theme.set_color("font_focus_color", "Button", BRASS_BRIGHT)
	theme.set_color("font_disabled_color", "Button", Color("68757a"))
	theme.set_font_size("font_size", "Button", 17)
	theme.set_stylebox("normal", "Button", panel(Color("152229"), Color("6e633f"), 1))
	theme.set_stylebox("hover", "Button", panel(Color("20323a"), BRASS, 2))
	theme.set_stylebox("pressed", "Button", panel(Color("0d171b"), BRASS_BRIGHT, 2))
	theme.set_stylebox("focus", "Button", panel(Color(0, 0, 0, 0), BRASS_BRIGHT, 2))
	theme.set_stylebox("disabled", "Button", panel(Color("11191d"), Color("39464a"), 1))
	theme.set_color("font_color", "CheckButton", IVORY)
	theme.set_color("font_color", "HSlider", IVORY)
	theme.set_stylebox("slider", "HSlider", panel(Color("26343a"), Color("26343a"), 0))
	theme.set_stylebox("grabber_area", "HSlider", panel(BRASS, BRASS, 0))
	theme.set_stylebox("grabber_area_highlight", "HSlider", panel(BRASS_BRIGHT, BRASS_BRIGHT, 0))
	theme.set_constant("separation", "VBoxContainer", 14)
	return theme

