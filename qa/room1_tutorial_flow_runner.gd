extends Node

const ReleaseWorld = preload("res://scripts/world_release_candidate.gd")

func _ready() -> void:
	call_deferred("run_suite")

func run_suite() -> void:
	var failures: Array[String] = []
	Game.current_level = 1
	Game.progress.completed = {}
	var world = ReleaseWorld.new()
	add_child(world)
	await get_tree().process_frame
	check_stage(world, 0, "MOVE RIGHT", failures)
	world.player.position.x = 180.0
	world.advance_room_one_tutorial()
	check_stage(world, 1, "OBSERVE", failures)
	world.player.position.x = 220.0
	world.advance_room_one_tutorial()
	check_stage(world, 2, "TRADE TO LIGHT", failures)
	world.exchanges = 1
	world.player.weight = 2
	world.advance_room_one_tutorial()
	check_stage(world, 3, "CROSS THE GAP", failures)
	world.player.position.x = 720.0
	world.advance_room_one_tutorial()
	check_stage(world, 4, "HEADWIND", failures)
	world.player.position.x = 940.0
	world.player.weight = 10
	world.advance_room_one_tutorial()
	check_stage(world, 5, "PRESSURE PLATE", failures)
	var gate: ProductionPressureGate
	for child in world.get_children():
		if child is ProductionPressureGate: gate = child; break
	if gate == null: failures.append("room one gate missing")
	else: gate.opened = true
	world.advance_room_one_tutorial()
	check_stage(world, 6, "COMMIT TO THE DROP", failures)
	world.player.position = Vector2(1380, 710)
	world.advance_room_one_tutorial()
	check_stage(world, 7, "TRADE BACK TO BALANCED", failures)
	world.player.position.x = 1750.0
	world.player.weight = 6
	world.advance_room_one_tutorial()
	check_stage(world, 8, "PRESS ONWARD", failures)
	world.player.position.x = 2100.0
	world.advance_room_one_tutorial()
	if world.tutorial_stage != 9: failures.append("tutorial did not complete")
	if failures.is_empty(): print("QA_PASS room 01 tutorial: nine contextual prompts follow the authored mechanics")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)

func check_stage(world, expected: int, phrase: String, failures: Array[String]) -> void:
	if world.tutorial_stage != expected: failures.append("stage %d expected, got %d" % [expected, world.tutorial_stage])
	if phrase not in world.tutorial_label.text: failures.append("stage %d missing copy: %s" % [expected, phrase])
