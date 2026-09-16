extends Node
const PerformanceWorld = preload("res://scripts/world_performance.gd")

func _ready() -> void: call_deferred("run_suite")

func run_suite() -> void:
	var failures: Array[String] = []
	for room_id in range(1, 25):
		Game.current_level = room_id
		var world = PerformanceWorld.new()
		add_child(world)
		await get_tree().process_frame
		await get_tree().physics_frame
		if not world.player is PerformanceBearer: failures.append("room %d performance player" % room_id)
		if world.find_children("*", "CharacterBody2D", true, false).size() != 1: failures.append("room %d player count" % room_id)
		if world.room_layout.is_empty(): failures.append("room %d layout" % room_id)
		remove_child(world)
		world.free()
	if failures.is_empty(): print("QA_PASS performance rooms: 24 rooms construct with one animated Bearer and valid layouts")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)

