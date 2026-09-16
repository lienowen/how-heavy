extends Node
func _ready() -> void:
	var failures: Array[String] = []
	for room_id in range(1, 25):
		var result := RoomReachabilitySolver.solve(LevelLayouts.room(room_id))
		if not bool(result.solved): failures.append("room %02d unsolved: %s (%d/%d surfaces, weights %s)" % [room_id, result.reason, result.reachable, result.surface_count, str(result.weights)])
	if failures.is_empty(): print("QA_PASS reachability: reproducible physics-envelope solver reaches all 24 exits with required weight resources")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)
