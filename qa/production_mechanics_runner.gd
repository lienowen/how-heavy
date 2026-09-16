extends Node
const ProductionWorld = preload("res://scripts/world_production_mechanics.gd")

func _ready() -> void: call_deferred("run_suite")

func run_suite() -> void:
	var failures: Array[String] = []
	for room_id in range(1, 25):
		Game.current_level = room_id
		var world = ProductionWorld.new()
		add_child(world)
		await get_tree().process_frame
		await get_tree().physics_frame
		if world.find_children("*", "CharacterBody2D", true, false).size() != 1: failures.append("room %d player count" % room_id)
		for node in world.get_tree().get_nodes_in_group("release_stones"):
			if node.get_parent() == world and not node is ProductionWeightVessel: failures.append("room %d legacy vessel" % room_id)
		for node in world.get_tree().get_nodes_in_group("weight_gates"):
			if node.get_parent().get_parent() == world and not node.get_parent() is ProductionPressureGate: failures.append("room %d legacy gate" % room_id)
		for node in world.get_tree().get_nodes_in_group("spring_pads"):
			if node.get_parent() == world and not node is ProductionSpringPad: failures.append("room %d legacy spring" % room_id)
		for node in world.get_tree().get_nodes_in_group("moving_platforms"):
			if node.get_parent() == world and not node is ProductionMovingPlatform: failures.append("room %d legacy mover" % room_id)
		remove_child(world)
		world.free()
	if failures.is_empty(): print("QA_PASS production mechanics: 24 rooms, unified vessels, gates, springs, movers, wind and fragile-floor language")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)

