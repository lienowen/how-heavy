extends Node
func _ready() -> void:
	var failures: Array[String] = []
	if Achievements.KNOWN_IDS.size() != 12: failures.append("catalog count")
	Achievements.unlocked.erase("FIRST_TRADE")
	if not Achievements.unlock("FIRST_TRADE"): failures.append("first unlock")
	if Achievements.unlock("FIRST_TRADE"): failures.append("duplicate unlock")
	Achievements.save_state()
	Achievements.unlocked.erase("FIRST_TRADE")
	Achievements.load_state()
	if not Achievements.is_unlocked("FIRST_TRADE"): failures.append("persistence")
	if Achievements.unlock("UNKNOWN"): failures.append("unknown accepted")
	if failures.is_empty(): print("QA_PASS achievements: 12 IDs, validation, idempotency, persistence")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)

