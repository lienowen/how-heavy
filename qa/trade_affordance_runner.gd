extends Node
const ReleaseWorld = preload("res://scripts/world_release_candidate.gd")
func _ready() -> void: call_deferred("run_suite")
func run_suite() -> void:
	Game.current_level = 1
	var world = ReleaseWorld.new()
	add_child(world)
	await get_tree().process_frame
	var vessels: Array[ReleaseStone] = []
	for child in world.get_children():
		if child is ReleaseStone: vessels.append(child)
	var failures: Array[String] = []
	if vessels.is_empty(): failures.append("room 1 has no vessel")
	else:
		var vessel := vessels[0]
		world.player.global_position = vessel.global_position
		world.player.weight = vessel.weight
		world.update_interaction()
		if world.player.nearby != null: failures.append("same-weight no-op target accepted")
		world.player.weight = 6
		vessel.weight = 2
		world.update_interaction()
		if world.player.nearby != vessel: failures.append("different-weight target not selected")
		else:
			Input.action_press("exchange")
			world.player._physics_process(1.0 / 120.0)
			Input.action_release("exchange")
			if world.player.weight != 2 or vessel.weight != 6: failures.append("runtime exchange failed")
	if failures.is_empty(): print("QA_PASS trade affordance: no-op blocked, explicit target selected, 6-to-2 runtime exchange")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)
