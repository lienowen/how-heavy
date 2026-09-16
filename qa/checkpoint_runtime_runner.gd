extends Node

const WorldType = preload("res://scripts/world_feedback_sequences.gd")
const MARKS: Array[float] = [780.0, 1880.0, 2660.0]
const TEST_WEIGHTS: Array[int] = [2, 6, 10]

func _ready() -> void:
	call_deferred("run_suite")

func run_suite() -> void:
	var room_id: int = requested_room()
	var failures: Array[String] = []
	var old_shake: bool = bool(Game.settings.screen_shake)
	Game.settings.screen_shake = false
	Game.current_level = room_id
	var world = WorldType.new()
	add_child(world)
	await get_tree().process_frame
	await get_tree().physics_frame
	for checkpoint_index: int in range(3):
		var threshold: float = MARKS[checkpoint_index]
		var landing: Vector2 = safe_landing_after(world.room_layout, threshold)
		if landing.x < 0.0:
			failures.append("checkpoint %d has no landing" % (checkpoint_index + 1))
			continue
		world.player.global_position = landing + Vector2(0.0, -18.0)
		world.player.velocity = Vector2.ZERO
		var landed := false
		for frame: int in range(45):
			await get_tree().physics_frame
			if world.player.is_on_floor():
				landed = true
				break
		if not landed:
			failures.append("checkpoint %d could not land" % (checkpoint_index + 1))
			continue
		world.update_checkpoint()
		if world.checkpoint_stage != checkpoint_index + 1:
			failures.append("checkpoint %d did not record" % (checkpoint_index + 1))
			continue
		var saved_position: Vector2 = world.checkpoint
		var saved_weight: int = TEST_WEIGHTS[checkpoint_index]
		world.player.weight = saved_weight
		world.checkpoint_weight = saved_weight
		world.player.global_position.y = 980.0
		world.player.fall_reported = true
		await world.on_fell()
		if world.player.global_position.distance_to(saved_position) > 2.0:
			failures.append("checkpoint %d restore position" % (checkpoint_index + 1))
		if world.player.weight != saved_weight or not world.player.controls_enabled:
			failures.append("checkpoint %d restore state" % (checkpoint_index + 1))
	Game.settings.screen_shake = old_shake
	if failures.is_empty():
		print("QA_PASS checkpoint room %02d: three grounded record/fall/restore cycles" % room_id)
	else:
		for failure in failures:
			push_error("room %02d %s" % [room_id, failure])
	world.queue_free()
	await get_tree().process_frame
	get_tree().quit(0 if failures.is_empty() else 1)

func requested_room() -> int:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("room="):
			return clampi(int(argument.trim_prefix("room=")), 1, 24)
	return 1

func safe_landing_after(layout: Dictionary, threshold: float) -> Vector2:
	var best := Vector2(-1, -1)
	for item in layout.platforms:
		var left: float = float(item[0])
		var right: float = left + float(item[2])
		var candidate_x: float = maxf(threshold + 12.0, left + 24.0)
		if candidate_x <= right - 24.0 and candidate_x <= threshold + 520.0:
			if best.x < 0.0 or candidate_x < best.x:
				best = Vector2(candidate_x, float(item[1]))
	return best
