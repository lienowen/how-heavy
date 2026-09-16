extends Node

const ReleaseWorld = preload("res://scripts/world_release_candidate.gd")

func _ready() -> void: call_deferred("run")

func run() -> void:
	Game.current_level = 1
	var world := ReleaseWorld.new()
	add_child(world)
	await get_tree().process_frame
	var failures: Array[String] = []
	var lower: Array = world.room_layout.platforms[2]
	if float(lower[1]) - float(world.room_layout.platforms[1][1]) < 85.0:
		failures.append("heavy landing drop is too small")
	var before_impacts := int(world.feedback.event_counts.impact)
	world.player.restore(Vector2(1380, 620), 10)
	for frame: int in range(120):
		await get_tree().physics_frame
		if world.player.is_on_floor(): break
	await get_tree().process_frame
	if int(world.feedback.event_counts.impact) != before_impacts + 1:
		failures.append("heavy landing feedback did not fire")
	if not world.audio_director.sounds.has("heavy_land"):
		failures.append("heavy landing sound is missing")
	var recovery_vessel_found := false
	for node in get_tree().get_nodes_in_group("release_stones"):
		if node is ReleaseStone and node.weight == 6 and absf(node.global_position.x - 1740.0) < 2.0:
			recovery_vessel_found = true
	if not recovery_vessel_found:
		failures.append("balanced recovery vessel is missing after the drop")
	if failures.is_empty(): print("QA_PASS room 01 heavy landing: authored drop, impact feedback and recovery vessel")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)
