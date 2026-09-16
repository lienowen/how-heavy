extends Node
func _ready() -> void:
	var failures: Array[String] = []
	var corrupt := {"progress":{"unlocked_level":999,"total_exchanges":-4,"total_deaths":"bad","ending":"invalid","completed":{"1":true,"25":true,"x":true},"best_times":{"1":12.345,"2":-4,"30":2}},"settings":{"master_volume":7,"music_volume":-2,"sfx_volume":"bad","text_scale":9,"language":"zh"}}
	Game.apply_validated_payload(corrupt)
	if Game.progress.unlocked_level != 24: failures.append("level clamp")
	if Game.progress.total_exchanges != 0 or Game.progress.total_deaths != 0: failures.append("counter clamp")
	if Game.progress.ending != "": failures.append("ending validation")
	if Game.progress.completed.size() != 1 or not Game.progress.completed.has("1"): failures.append("completed filtering")
	if Game.progress.best_times.size() != 1: failures.append("time filtering")
	if Game.settings.master_volume != 1.0 or Game.settings.music_volume != 0.0: failures.append("volume clamp")
	if Game.settings.text_scale != 1.4 or Game.settings.language != "en": failures.append("settings normalization")
	Achievements.apply_achievement_payload({"unlocked":{"FIRST_TRADE":1,"FAKE":2}})
	if Achievements.unlocked.size() != 1 or not Achievements.is_unlocked("FIRST_TRADE"): failures.append("achievement filtering")
	if Game.is_valid_payload(JSON.parse_string("{broken")): failures.append("corrupt JSON accepted")
	if failures.is_empty(): print("QA_PASS resilience: corrupt save rejected, progress/settings/achievements sanitized")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)

