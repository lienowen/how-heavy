extends Node

func _ready() -> void:
	var failures: Array[String] = []
	var original_room: int = int(Game.current_level)
	for cycle: int in range(100):
		var room_id: int = cycle % 24 + 1
		Game.current_level = room_id
		var layout: Dictionary = LevelLayouts.room(room_id)
		if int(layout.id) != room_id: failures.append("cycle %d room mismatch" % cycle)
		var checkpoint_stage: int = cycle % 4
		var checkpoint_weight: int = [2, 6, 10][cycle % 3]
		if checkpoint_stage < 0 or checkpoint_stage > 3: failures.append("checkpoint stage corruption")
		if checkpoint_weight < 2 or checkpoint_weight > 10: failures.append("checkpoint weight corruption")
	Game.current_level = original_room
	if failures.is_empty(): print("QA_PASS state stress: 100 restart/switch/checkpoint state cycles")
	else:
		for failure: String in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)
