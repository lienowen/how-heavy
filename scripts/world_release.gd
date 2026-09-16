extends "res://scripts/world.gd"

func on_impact(at: Vector2, _speed: float) -> void:
	if broken or at.x < 3090:
		return
	broken = true
	for child in fragile.get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
	fragile.visible = false
	queue_redraw()
