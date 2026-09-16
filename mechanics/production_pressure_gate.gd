class_name ProductionPressureGate
extends PressureGate

var open_progress := 0.0

func _physics_process(delta: float) -> void:
	var was_open := opened
	super(delta)
	open_progress = move_toward(open_progress, 1.0 if opened else 0.0, delta * 3.6)
	if was_open != opened or open_progress > 0.0: queue_redraw()

func _draw() -> void:
	if plate == null: return
	var brass := Color("dfbd68")
	var graphite := Color("17252a")
	var plate_rect := Rect2(plate.position - Vector2(64, 10), Vector2(128, 20))
	draw_rect(plate_rect, Color("101a1e"))
	draw_rect(Rect2(plate_rect.position + Vector2(4, 3), Vector2(120, 10)), brass if opened else Color("756744"))
	for x in range(-48, 49, 24): draw_line(plate.position + Vector2(x, -7), plate.position + Vector2(x, 3), Color("f0d783"), 1.5)
	var lift := open_progress * 205.0
	var gate_center := gate.position - Vector2(0, lift)
	draw_rect(Rect2(gate.position - Vector2(35, 123), Vector2(70, 246)), Color(0.02, 0.03, 0.035, 0.8), false, 4)
	draw_rect(Rect2(gate_center - Vector2(24, 115), Vector2(48, 230)), graphite)
	draw_line(gate_center + Vector2(-24, -115), gate_center + Vector2(-24, 115), brass, 4)
	draw_line(gate_center + Vector2(24, -115), gate_center + Vector2(24, 115), brass, 4)
	for y in range(-92, 101, 32):
		draw_line(gate_center + Vector2(-18, y), gate_center + Vector2(18, y), Color("71868a"), 3)
	draw_arc(gate.position + Vector2(0, -133), 18, 0, TAU, 32, brass, 3)
	var label := str(threshold)
	draw_string(ThemeDB.fallback_font, gate.position + Vector2(-7, -127), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("f4ead2"))

