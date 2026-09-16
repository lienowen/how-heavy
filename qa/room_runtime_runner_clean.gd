extends Node
const RuntimeWorld = preload("res://scripts/world_commercial_feedback_fixed.gd")
func _ready() -> void: call_deferred("run_suite")
func run_suite() -> void:
	var failures: Array[String] = []
	for room_id in range(1, 25):
		Game.current_level = room_id
		var world = RuntimeWorld.new()
		add_child(world)
		await get_tree().process_frame
		await get_tree().physics_frame
		var players := world.find_children("*", "CharacterBody2D", true, false)
		if players.size() != 1: failures.append("room %d player count %d" % [room_id, players.size()])
		if world.level_id != room_id: failures.append("room %d loaded as %d" % [room_id, world.level_id])
		if world.room_layout.is_empty(): failures.append("room %d empty layout" % room_id)
		if world.checkpoint_stage != 0: failures.append("room %d initial checkpoint" % room_id)
		if not is_instance_valid(world.fragile): failures.append("room %d fragile state" % room_id)
		remove_child(world)
		world.free()
	if failures.is_empty(): print("QA_PASS runtime: 24 rooms construct, exactly one player, valid layout/checkpoint/fragile state")
	else:
		for failure in failures: push_error(failure)
	await get_tree().process_frame
	get_tree().quit(0 if failures.is_empty() else 1)

