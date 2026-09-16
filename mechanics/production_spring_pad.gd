class_name ProductionSpringPad
extends WeightSpringPad

var compression := 0.0

func _process(delta: float) -> void:
	super(delta)
	compression = move_toward(compression, 0.0, delta * 4.5)
	queue_redraw()

func on_body_entered(body: Node) -> void:
	var ready_to_fire := cooldown <= 0.0 and body is ReleasePlayer
	super(body)
	if ready_to_fire: compression = 1.0

func _draw() -> void:
	var top_y := lerpf(-15.0, -5.0, compression)
	draw_rect(Rect2(-60, 7, 120, 12), Color("111b20"))
	draw_line(Vector2(-56, 7), Vector2(56, 7), Color("806f43"), 3)
	for x in range(-42, 43, 21):
		draw_polyline(PackedVector2Array([Vector2(x, 6), Vector2(x + 9, -2), Vector2(x, top_y), Vector2(x + 9, top_y)]), Color("d7b85a"), 3, true)
	draw_rect(Rect2(-57, top_y - 7, 114, 11), Color("26383d"))
	draw_line(Vector2(-52, top_y - 7), Vector2(52, top_y - 7), Color("e0c06b"), 3)
	for x in range(-40, 41, 20): draw_line(Vector2(x, top_y - 7), Vector2(x, top_y), Color("75c8cc"), 2)

