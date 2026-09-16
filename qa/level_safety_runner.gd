extends Node

func _ready() -> void:
	var failures: Array[String] = []
	var room_fingerprints := {}
	for room_id in range(1, 25):
		var layout := LevelLayouts.room(room_id)
		for issue in LevelSafetyAnalyzer.analyze(room_id, layout): failures.append("room %02d: %s" % [room_id, issue])
		var fingerprint := LevelLayouts.signature(room_id)
		if room_fingerprints.has(fingerprint): failures.append("room %02d duplicates room %02d" % [room_id, int(room_fingerprints[fingerprint])])
		else: room_fingerprints[fingerprint] = room_id
	if failures.is_empty(): print("QA_PASS level safety: 24 starts/exits, recovery zones, weight resources, gates, fragile floors and geometry chains")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)

