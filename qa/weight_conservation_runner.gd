extends Node

const WorldType = preload("res://scripts/world_feedback_sequences.gd")

func _ready() -> void:
	call_deferred("run_suite")

func run_suite() -> void:
	var failures: Array[String] = []
	var old_shake: bool = bool(Game.settings.screen_shake)
	Game.settings.screen_shake = false
	for room_id: int in range(1, 25):
		Game.current_level = room_id
		var world = WorldType.new()
		add_child(world)
		await get_tree().process_frame
		var vessels: Array[Node] = []
		for node in get_tree().get_nodes_in_group("release_stones"):
			if node.is_ancestor_of(world) or world.is_ancestor_of(node):
				vessels.append(node)
		var expected_count: int = world.room_layout.stones.size()
		if vessels.size() != expected_count:
			failures.append("room %02d vessel count" % room_id)
		var original_total: int = world.player.weight
		for vessel in vessels: original_total += int(vessel.weight)
		for cycle: int in range(100):
			var vessel: Node = vessels[cycle % vessels.size()]
			var held: int = world.player.weight
			world.player.weight = int(vessel.weight)
			vessel.weight = held
			var total: int = world.player.weight
			for item in vessels: total += int(item.weight)
			if total != original_total:
				failures.append("room %02d weight lost at trade %d" % [room_id, cycle])
				break
		world.queue_free()
		await get_tree().process_frame
	Game.settings.screen_shake = old_shake
	if failures.is_empty():
		print("QA_PASS weight conservation: 24 rooms, 2400 exchanges, zero lost resources")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)
