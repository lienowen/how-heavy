class_name ProductionFeedback
extends Control

enum Sequence { NONE, EXCHANGE, IMPACT, GATE, CHECKPOINT, FAILURE, COMPLETE }

var sequence: Sequence = Sequence.NONE
var elapsed: float = 0.0
var duration: float = 0.0
var focus: Vector2 = Vector2(640, 360)
var event_counts := {"exchange": 0, "impact": 0, "gate": 0, "checkpoint": 0, "failure": 0, "complete": 0}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 100

func play_exchange(at: Vector2) -> void:
	event_counts.exchange += 1
	start(Sequence.EXCHANGE, 0.42, at)
func play_impact(at: Vector2) -> void:
	event_counts.impact += 1
	start(Sequence.IMPACT, 0.48, at)
func play_gate(at: Vector2) -> void:
	event_counts.gate += 1
	start(Sequence.GATE, 0.7, at)
func play_checkpoint(at: Vector2) -> void:
	event_counts.checkpoint += 1
	start(Sequence.CHECKPOINT, 1.15, at)
func play_failure(at: Vector2) -> void:
	event_counts.failure += 1
	start(Sequence.FAILURE, 0.58, at)
func play_complete(at: Vector2) -> void:
	event_counts.complete += 1
	start(Sequence.COMPLETE, 1.4, at)
func start(next: Sequence, seconds: float, at: Vector2) -> void:
	sequence = next
	elapsed = 0.0
	duration = seconds
	focus = at
	queue_redraw()
func _process(delta: float) -> void:
	if sequence == Sequence.NONE: return
	elapsed += delta
	if elapsed >= duration: sequence = Sequence.NONE
	queue_redraw()
func progress() -> float:
	return clampf(elapsed / maxf(duration, 0.001), 0.0, 1.0)

func _draw() -> void:
	if sequence == Sequence.NONE: return
	var t := progress()
	var reduced := bool(Game.settings.reduced_flashes)
	match sequence:
		Sequence.EXCHANGE:
			var alpha := (1.0 - t) * (0.38 if reduced else 0.72)
			draw_arc(focus, 32.0 + t * 105.0, 0, TAU, 64, Color(0.45, 0.9, 0.92, alpha), 5.0 - t * 2.0)
			draw_arc(focus, 18.0 + t * 72.0, -PI * 0.65, PI * 0.35, 42, Color(0.9, 0.75, 0.38, alpha), 3.0)
		Sequence.IMPACT:
			var force := 1.0 - t
			draw_rect(Rect2(0, 0, size.x, size.y), Color(0.72, 0.42, 0.18, force * (0.05 if reduced else 0.12)))
			for i in range(8):
				var angle := -PI * 0.92 + i * PI * 0.12
				draw_line(focus, focus + Vector2(cos(angle), sin(angle)) * (55.0 + t * 150.0), Color(0.9, 0.7, 0.35, force * 0.72), 3)
		Sequence.GATE:
			var fade := 1.0 - t
			draw_circle(focus, 36.0 + t * 120.0, Color(0.91, 0.72, 0.3, 0.08 * fade), false, 5)
			for i in range(6):
				var y := focus.y - 100.0 + i * 38.0
				draw_line(Vector2(focus.x - 44.0 - t * 38.0, y), Vector2(focus.x + 44.0 + t * 38.0, y), Color(0.94, 0.78, 0.4, fade * 0.7), 3)
		Sequence.CHECKPOINT:
			var reveal := sin(clampf(t * 1.4, 0.0, 1.0) * PI * 0.5)
			var fade := 1.0 - clampf((t - 0.7) / 0.3, 0.0, 1.0)
			draw_arc(focus, 30.0 + reveal * 26.0, -PI * 0.5, -PI * 0.5 + TAU * reveal, 48, Color(0.47, 0.82, 0.82, fade * 0.85), 4)
			draw_line(focus + Vector2(-16, 1), focus + Vector2(-3, 15), Color(0.9, 0.82, 0.5, fade), 4)
			draw_line(focus + Vector2(-3, 15), focus + Vector2(20, -13), Color(0.9, 0.82, 0.5, fade), 4)
		Sequence.FAILURE:
			var cover := sin(t * PI)
			draw_rect(Rect2(0, 0, size.x, size.y), Color(0.02, 0.025, 0.03, cover * 0.74))
			draw_arc(focus, 85.0 - t * 45.0, 0, TAU, 48, Color(0.65, 0.24, 0.18, (1.0 - t) * 0.55), 5)
		Sequence.COMPLETE:
			var reveal := sin(clampf(t * 1.6, 0.0, 1.0) * PI * 0.5)
			draw_rect(Rect2(0, 0, size.x, 42.0 * reveal), Color(0.025, 0.035, 0.04, 0.92))
			draw_rect(Rect2(0, size.y - 42.0 * reveal, size.x, 42.0 * reveal), Color(0.025, 0.035, 0.04, 0.92))
			for i in range(12):
				var angle := i * TAU / 12.0 + t * 0.12
				draw_line(focus + Vector2(cos(angle), sin(angle)) * 55, focus + Vector2(cos(angle), sin(angle)) * (90 + reveal * 110), Color(0.86, 0.71, 0.34, (1.0 - t * 0.55) * 0.42), 2)
