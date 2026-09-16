extends "res://systems/game_service_commercial.gd"

func load_state() -> void:
	var loaded = read_state(SAVE_PATH)
	if not is_valid_payload(loaded): loaded = read_state(BACKUP_PATH)
	apply_validated_payload(loaded)

func is_valid_payload(value) -> bool:
	return value is Dictionary and value.get("progress", null) is Dictionary and value.get("settings", null) is Dictionary

func apply_validated_payload(value) -> void:
	if is_valid_payload(value):
		var incoming_progress: Dictionary = value.progress
		var incoming_settings: Dictionary = value.settings
		progress.merge(incoming_progress, true)
		settings.merge(incoming_settings, true)
	sanitize_state()

func sanitize_state() -> void:
	progress.version = SAVE_VERSION
	progress.unlocked_level = clampi(safe_int(progress.get("unlocked_level", 1), 1), 1, 24)
	progress.total_exchanges = maxi(safe_int(progress.get("total_exchanges", 0), 0), 0)
	progress.total_deaths = maxi(safe_int(progress.get("total_deaths", 0), 0), 0)
	if str(progress.get("ending", "")) not in ["", "release", "carry"]: progress.ending = ""
	progress.completed = sanitize_completed(progress.get("completed", {}))
	progress.best_times = sanitize_times(progress.get("best_times", {}))
	settings.master_volume = safe_volume(settings.get("master_volume", 0.8), 0.8)
	settings.music_volume = safe_volume(settings.get("music_volume", 0.7), 0.7)
	settings.sfx_volume = safe_volume(settings.get("sfx_volume", 0.9), 0.9)
	settings.text_scale = clampf(safe_float(settings.get("text_scale", 1.0), 1.0), 0.8, 1.4)
	settings.fullscreen = bool(settings.get("fullscreen", false))
	settings.screen_shake = bool(settings.get("screen_shake", true))
	settings.high_contrast = bool(settings.get("high_contrast", false))
	settings.reduced_flashes = bool(settings.get("reduced_flashes", false))
	settings.assist_mode = bool(settings.get("assist_mode", false))
	settings.language = "en"

func sanitize_completed(value) -> Dictionary:
	var result := {}
	if value is Dictionary:
		for key in value:
			var room := safe_int(key, 0)
			if room >= 1 and room <= 24 and bool(value[key]): result[str(room)] = true
	return result

func sanitize_times(value) -> Dictionary:
	var result := {}
	if value is Dictionary:
		for key in value:
			var room := safe_int(key, 0)
			var seconds := safe_float(value[key], -1.0)
			if room >= 1 and room <= 24 and seconds > 0.0 and seconds < 86400.0: result[str(room)] = snappedf(seconds, 0.01)
	return result

func safe_int(value, fallback: int = 0) -> int:
	if value is int or value is float or value is String and str(value).is_valid_int(): return int(value)
	return fallback

func safe_float(value, fallback: float = 0.0) -> float:
	if value is int or value is float: return float(value)
	if value is String and str(value).is_valid_float(): return float(value)
	return fallback

func safe_volume(value, fallback: float) -> float:
	return clampf(safe_float(value, fallback), 0.0, 1.0)

