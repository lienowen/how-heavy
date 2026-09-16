class_name WeightAtmosphere
extends Control

var current_weight := 6
var target_weight := -1
var player_focus := Vector2(320, 600)
var target_focus := Vector2.ZERO
var wind_strength := 0.0
var wind_presence := 0.0
var motion := 0.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 90

func set_state(weight: int, player_at: Vector2, target_at: Vector2, target: int, wind: float) -> void:
	current_weight = weight
	player_focus = player_at
	target_focus = target_at
	target_weight = target
	wind_strength = wind
	queue_redraw()

func _process(delta: float) -> void:
	motion += delta
	var desired := 1.0 if wind_strength > 0.0 else 0.0
	wind_presence = move_toward(wind_presence, desired, delta * (4.5 if desired > wind_presence else 3.0))
	queue_redraw()

func _draw() -> void:
	var reduced := bool(Game.settings.reduced_flashes)
	var intensity := 0.45 if reduced else 1.0
	if current_weight <= 3:
		draw_rect(Rect2(0, 0, size.x, size.y), Color(0.16, 0.55, 0.62, 0.035 * intensity))
		for i in range(9):
			var y := 150.0 + i * 58.0
			var x := fposmod(motion * (90.0 + i * 7.0) + i * 173.0, size.x + 280.0) - 140.0
			draw_line(Vector2(x - 55, y), Vector2(x + 55, y - 10), Color(0.52, 0.9, 0.94, 0.22 * intensity), 2)
	elif current_weight >= 9:
		draw_rect(Rect2(0, 0, size.x, 18), Color(0.78, 0.51, 0.18, 0.22 * intensity))
		draw_rect(Rect2(0, size.y - 22, size.x, 22), Color(0.04, 0.025, 0.015, 0.54 * intensity))
		for i in range(8):
			var x := 80.0 + i * 165.0
			var fall := fposmod(motion * 70.0 + i * 91.0, 180.0)
			draw_line(Vector2(x, 80 + fall), Vector2(x, 108 + fall), Color(0.88, 0.67, 0.28, 0.25 * intensity), 3)
	if wind_presence > 0.01:
		var alpha := wind_presence * intensity
		draw_rect(Rect2(0, 0, 18, size.y), Color(0.25, 0.76, 0.84, 0.14 * alpha))
		for i in range(12):
			var y := 95.0 + i * 48.0
			var x := size.x - fposmod(motion * (260.0 + i * 9.0) + i * 127.0, size.x + 220.0)
			draw_line(Vector2(x + 84, y - 8), Vector2(x - 28, y + 8), Color(0.65, 0.94, 0.97, 0.28 * alpha), 3)
		var wind_text := "HEADWIND  ◀"
		draw_string(ThemeDB.fallback_font, Vector2(size.x * 0.5 - 64, 142), wind_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.75, 0.94, 0.96, 0.78 * alpha))
	if target_weight >= 0:
		var pulse := 0.72 + sin(motion * 6.0) * 0.18
		draw_dashed_line(player_focus, target_focus, Color(0.46, 0.91, 0.92, pulse), 8, 14)
		draw_circle(target_focus, 62 + sin(motion * 5.0) * 4, Color(0.48, 0.9, 0.9, 0.07), false, 5)
		var mid := player_focus.lerp(target_focus, 0.5)
		var label := "%d  →  %d" % [current_weight, target_weight]
		draw_string(ThemeDB.fallback_font, mid + Vector2(-34, -18), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("f6dfa1"))
