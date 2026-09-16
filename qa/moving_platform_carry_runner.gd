extends Node
const ReleaseWorld = preload("res://scripts/world_release_candidate.gd")
func _ready() -> void: call_deferred("run_suite")
func run_suite() -> void:
	var failures: Array[String] = []
	var checks := 0
	for room_id: int in range(1, 25):
		var mover_count: int = LevelLayouts.room(room_id).movers.size()
		for mover_index: int in range(mover_count):
			Game.current_level = room_id
			var world = ReleaseWorld.new()
			add_child(world)
			await get_tree().process_frame
			world.set_process(false)
			var movers: Array[ProductionMovingPlatform] = []
			for child in world.get_children():
				if child is ProductionMovingPlatform: movers.append(child)
			checks += 1
			if mover_index >= movers.size():
				failures.append("room %02d mover %d missing" % [room_id, mover_index])
				world.queue_free(); await get_tree().process_frame; continue
			var mover := movers[mover_index]
			mover.set_physics_process(false)
			await get_tree().physics_frame
			world.player.restore(mover.global_position + Vector2(0, -20), 6)
			var landed := false
			for frame: int in range(30):
				await get_tree().physics_frame
				if world.player.is_on_floor(): landed = true; break
			if not landed:
				failures.append("room %02d mover %d contact" % [room_id, mover_index])
			else:
				mover.set_physics_process(true)
				for frame: int in range(45): await get_tree().physics_frame
				var relative: Vector2 = world.player.global_position - mover.global_position
				var overlap_limit: float = mover.size.x * 0.5 + 16.0
				if not world.player.is_on_floor(): failures.append("room %02d mover %d lost grounding" % [room_id, mover_index])
				elif world.player.global_position.y >= 940.0: failures.append("room %02d mover %d dropped out" % [room_id, mover_index])
				elif absf(relative.x) > overlap_limit or relative.y < -35.0 or relative.y > 8.0:
					failures.append("room %02d mover %d carry %s" % [room_id, mover_index, relative])
			world.queue_free()
			await get_tree().process_frame
	if checks != 21: failures.append("mover coverage %d" % checks)
	if failures.is_empty(): print("QA_PASS moving platforms: 21 isolated landing-and-carry checks")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)
