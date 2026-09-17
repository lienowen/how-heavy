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
	var desired := 1.0 if absf(wind_strength) > 1.0 else 0.0
	wind_presence = move_toward(wind_presence, desired, delta * (4.5 if desired > wind_presence else 3.0))
	queue_redraw()

func _draw() -> void:
	var reduced := bool(Game.settings.reduced_flashes)
	var intensity := 0.45 if reduced else 1.0

	# Keep global overlays out of normal traversal. Wind gets a few directional streaks only.
	if wind_presence > 0.01:
		var alpha := wind_presence * intensity
		var dir := -1.0 if wind_strength > 0.0 else 1.0
		for i in range(7):
			var y := 245.0 + i * 54.0
			var travel := fposmod(motion * (220.0 + i * 11.0) + i * 137.0, size.x + 240.0)
			var x := size.x + 80.0 - travel if dir < 0.0 else -80.0 + travel
			draw_line(Vector2(x - dir * 42.0, y - 4), Vector2(x + dir * 42.0, y + 4), Color(0.78, 0.95, 1.0, 0.20 * alpha), 2)

	# Interaction feedback stays local to the object. No full-screen dashed connector or floating equation.
	if target_weight >= 0:
		var ring_alpha := (0.28 + sin(motion * 5.0) * 0.07) * intensity
		draw_arc(target_focus, 48.0 + sin(motion * 5.0) * 2.0, 0, TAU, 40, Color(0.55, 0.93, 0.92, ring_alpha), 3)
