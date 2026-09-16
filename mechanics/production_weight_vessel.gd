class_name ProductionWeightVessel
extends ReleaseStone

var pulse := 0.0

func _process(delta: float) -> void:
	pulse += delta * (3.2 if active else 1.1)
	if active: queue_redraw()

func _draw() -> void:
	var brass := Color("e0bd68") if active else Color("8e7845")
	var glow := 0.16 + sin(pulse) * 0.035 if active else 0.0
	if active:
		draw_circle(Vector2.ZERO, 57, Color(0.45, 0.9, 0.9, glow))
		draw_arc(Vector2.ZERO, 52, 0, TAU, 64, Color(0.48, 0.84, 0.84, 0.7), 2)
	draw_circle(Vector2(0, 3), 41, Color("111a1e"))
	draw_circle(Vector2(0, 3), 34, Color("28363a"))
	draw_arc(Vector2(0, 3), 41, 0, TAU, 64, brass, 4)
	draw_arc(Vector2(0, 3), 31, 0, TAU, 64, Color("4d583f"), 2)
	for i in range(12):
		var a := i * TAU / 12.0
		var p1 := Vector2(cos(a), sin(a)) * 35 + Vector2(0, 3)
		var p2 := Vector2(cos(a), sin(a)) * 41 + Vector2(0, 3)
		draw_line(p1, p2, brass, 1.5)
	draw_line(Vector2(-18, -43), Vector2(18, -43), brass, 4)
	draw_line(Vector2(-13, -48), Vector2(13, -48), Color("48565a"), 3)
	var label := str(weight)
	var font := ThemeDB.fallback_font
	var text_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 23)
	draw_string(font, Vector2(-text_size.x * 0.5, 11), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("f4ead2"))

