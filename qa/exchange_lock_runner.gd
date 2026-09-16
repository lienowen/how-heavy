extends Node
const ReleaseWorld = preload("res://scripts/world_release_candidate.gd")
func _ready() -> void: call_deferred("run_suite")
func run_suite() -> void:
	Game.current_level = 1
	var world = ReleaseWorld.new()
	add_child(world)
	await get_tree().process_frame
	var vessel: ReleaseStone
	for child in world.get_children():
		if child is ReleaseStone:
			vessel = child
			break
	var failures: Array[String] = []
	if vessel == null: failures.append("missing opening vessel")
	else:
		world.player.global_position = vessel.global_position
		world.player.weight = 6
		vessel.weight = 2
		world.update_interaction()
		Input.action_press("exchange")
		world.player._physics_process(1.0 / 120.0)
		world.player._physics_process(1.0 / 120.0)
		Input.action_release("exchange")
		if world.player.weight != 2 or vessel.weight != 6: failures.append("exchange did not resolve once")
		if world.player.exchange_lock <= 0.0: failures.append("exchange lock missing")
		var opening: Vector2 = Vector2(100, 620)
		if opening.distance_to(vessel.global_position) < 160.0: failures.append("opening vessel too close to spawn")
	if failures.is_empty(): print("QA_PASS stage 1: exchange locks once and opening vessel is readable")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)
