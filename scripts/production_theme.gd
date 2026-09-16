class_name ProductionTheme
extends RefCounted

const INK := Color("17324d")
const INK_2 := Color("244866")
const SKY := Color("78d7ff")
const SKY_DEEP := Color("45b8f0")
const CREAM := Color("fffaf0")
const MUTED := Color("6f8fa7")
const CYAN := Color("28d7d0")
const BLUE := Color("3f8cff")
const ORANGE := Color("ff9a3d")
const GREEN := Color("57d46f")
const DANGER := Color("ff5f66")
const WHITE := Color("ffffff")

static func panel(fill := Color(1.0, 1.0, 1.0, 0.92), border := Color("cfeeff"), width := 2, radius := 18) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(width)
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	box.content_margin_left = 20
	box.content_margin_right = 20
	box.content_margin_top = 14
	box.content_margin_bottom = 14
	box.shadow_color = Color(0.08, 0.2, 0.32, 0.18)
	box.shadow_size = 8
	box.shadow_offset = Vector2(0, 5)
	return box

static func button_box(fill: Color, border: Color, radius := 18) -> StyleBoxFlat:
	var box := panel(fill, border, 2, radius)
	box.content_margin_top = 12
	box.content_margin_bottom = 12
	box.shadow_color = Color(0.04, 0.15, 0.24, 0.22)
	box.shadow_size = 7
	box.shadow_offset = Vector2(0, 5)
	return box

static func build() -> Theme:
	var theme := Theme.new()

	theme.set_color("font_color", "Label", INK)
	theme.set_color("font_shadow_color", "Label", Color(1, 1, 1, 0.72))
	theme.set_constant("shadow_offset_x", "Label", 0)
	theme.set_constant("shadow_offset_y", "Label", 2)
	theme.set_font_size("font_size", "Label", 17)

	theme.set_stylebox("panel", "PanelContainer", panel())

	theme.set_color("font_color", "Button", WHITE)
	theme.set_color("font_hover_color", "Button", WHITE)
	theme.set_color("font_focus_color", "Button", WHITE)
	theme.set_color("font_pressed_color", "Button", WHITE)
	theme.set_color("font_disabled_color", "Button", Color("9fb4c4"))
	theme.set_font_size("font_size", "Button", 18)
	theme.set_stylebox("normal", "Button", button_box(BLUE, Color("9bc8ff")))
	theme.set_stylebox("hover", "Button", button_box(Color("54a2ff"), Color("dff1ff"), 20))
	theme.set_stylebox("pressed", "Button", button_box(Color("2f74e7"), Color("dff1ff"), 18))
	theme.set_stylebox("focus", "Button", button_box(BLUE, WHITE, 20))
	theme.set_stylebox("disabled", "Button", button_box(Color("dce7ee"), Color("c6d4de")))

	theme.set_color("font_color", "CheckButton", INK)
	theme.set_color("font_color", "HSlider", INK)
	theme.set_stylebox("slider", "HSlider", panel(Color("d8edf7"), Color("d8edf7"), 0, 8))
	theme.set_stylebox("grabber_area", "HSlider", panel(CYAN, CYAN, 0, 8))
	theme.set_stylebox("grabber_area_highlight", "HSlider", panel(Color("44efe6"), Color("44efe6"), 0, 8))

	theme.set_constant("separation", "VBoxContainer", 16)
	return theme
