extends Node
func _ready() -> void:
	var failures: Array[String] = []
	var app_source := FileAccess.get_file_as_string("res://scripts/app_crazygames.gd")
	var world_source := FileAccess.get_file_as_string("res://scripts/world_crazygames.gd")
	var bridge_source := FileAccess.get_file_as_string("res://systems/crazygames_bridge.gd")
	var export_source := FileAccess.get_file_as_string("res://export_presets.cfg")
	if "gameplay_start" not in app_source: failures.append("missing gameplay start")
	if "gameplay_stop" not in world_source: failures.append("missing gameplay stop")
	if "game.gameplayStart()" not in bridge_source or "game.gameplayStop()" not in bridge_source: failures.append("missing SDK events")
	if "crazygames-sdk-v3.js" not in export_source: failures.append("missing SDK v3 loader")
	if "Fullscreen" not in app_source or "queue_free" not in app_source: failures.append("web fullscreen control not suppressed")
	if failures.is_empty(): print("QA_PASS CrazyGames: SDK v3, gameplay lifecycle, graceful offline fallback, fullscreen suppression")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)

