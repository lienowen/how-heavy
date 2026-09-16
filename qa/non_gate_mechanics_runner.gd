extends Node
const ProductionWorld = preload("res://scripts/world_production_mechanics.gd")
func _ready() -> void: call_deferred("run_suite")
func run_suite() -> void:
	var failures: Array[String] = []
	var counts := {"springs": 0, "movers": 0, "fragile": 0}
	for room_id: int in range(1, 25):
		Game.current_level = room_id
		var world = ProductionWorld.new()
		add_child(world)
		await get_tree().process_frame
		world.set_process(false)
		world.player.controls_enabled = false
		for child in world.get_children():
			if child is ProductionSpringPad:
				counts.springs += 1
				for weight: int in [2, 10]:
					world.player.weight = weight
					world.player.velocity = Vector2(0, 180)
					child.cooldown = 0.0
					child.on_body_entered(world.player)
					var target_velocity: float = -child.power if weight == 2 else -child.power * 0.64
					if absf(world.player.velocity.y - target_velocity) > 0.1: failures.append("room %02d spring weight %d" % [room_id, weight])
			elif child is ProductionMovingPlatform:
				counts.movers += 1
				var phase_before: float = child.phase
				await get_tree().physics_frame
				await get_tree().physics_frame
				var target_position: Vector2 = child.origin + child.travel * ((sin(child.phase) + 1.0) * 0.5)
				var mover_shapes: Array[Node] = child.find_children("*", "CollisionShape2D", true, false)
				if child.phase <= phase_before or child.position.distance_to(target_position) > 0.5: failures.append("room %02d mover sync" % room_id)
				if mover_shapes.is_empty() or (mover_shapes[0] as CollisionShape2D).disabled: failures.append("room %02d mover collision" % room_id)
		if world.needs_break:
			counts.fragile += 1
			world.on_impact(Vector2(3140, 670), 700.0)
			await get_tree().physics_frame
			var fragile_shapes: Array[Node] = world.fragile.find_children("*", "CollisionShape2D", true, false)
			if not world.broken or world.fragile.visible or fragile_shapes.is_empty() or not (fragile_shapes[0] as CollisionShape2D).disabled: failures.append("room %02d fragile state" % room_id)
		world.queue_free()
		await get_tree().process_frame
	if int(counts.springs) != 8: failures.append("spring coverage %d" % counts.springs)
	if int(counts.movers) != 21: failures.append("mover coverage %d" % counts.movers)
	if int(counts.fragile) != 7: failures.append("fragile coverage %d" % counts.fragile)
	if failures.is_empty(): print("QA_PASS non-gate mechanics: 8 springs x2 weights, 21 synced movers, 7 fragile floors")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)
