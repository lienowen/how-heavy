class_name ProductionMovingPlatform
extends WeightMovingPlatform

func _draw() -> void:
	var rect := Rect2(-size * 0.5, size)
	draw_rect(rect, Color("132126"))
	draw_rect(Rect2(rect.position + Vector2(5, 5), rect.size - Vector2(10, 10)), Color("26373c"))
	draw_line(Vector2(-size.x * 0.5, -size.y * 0.5), Vector2(size.x * 0.5, -size.y * 0.5), Color("dfbd68"), 4)
	for x in range(int(-size.x * 0.4), int(size.x * 0.4) + 1, 24):
		draw_line(Vector2(x, -size.y * 0.5), Vector2(x, -size.y * 0.5 + 7), Color("f1d984"), 1.5)
	draw_circle(Vector2(-size.x * 0.38, 1), 5, Color("806e43"))
	draw_circle(Vector2(size.x * 0.38, 1), 5, Color("806e43"))

