extends Node

const SAVE_PATH := "user://campaign.json"
const BACKUP_PATH := "user://campaign.backup.json"
const TEMP_PATH := "user://campaign.tmp.json"
const SAVE_VERSION := 2
var current_level := 1
var progress := {"version":SAVE_VERSION,"unlocked_level":1,"completed":{},"best_times":{},"total_exchanges":0,"total_deaths":0,"ending":""}
var settings := {"master_volume":0.8,"music_volume":0.7,"sfx_volume":0.9,"fullscreen":false,"screen_shake":true,"high_contrast":false,"reduced_flashes":false,"assist_mode":false,"text_scale":1.0,"language":"en"}

func _ready() -> void:
	load_state()
	apply_settings()

func complete_level(level_id: int, time: float, exchanges: int, deaths: int) -> void:
	var key := str(level_id)
	progress.completed[key] = true
	progress.unlocked_level = maxi(int(progress.unlocked_level), mini(level_id + 1, 24))
	if not progress.best_times.has(key) or time < float(progress.best_times[key]): progress.best_times[key] = snappedf(time, 0.01)
	progress.total_exchanges += exchanges
	progress.total_deaths += deaths
	save_state()

func save_settings() -> void:
	save_state()
	apply_settings()

func save_state() -> void:
	var payload := {"version":SAVE_VERSION,"progress":progress,"settings":settings}
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null: return
	file.store_string(JSON.stringify(payload, "  "))
	file.close()
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(BACKUP_PATH)
		DirAccess.rename_absolute(SAVE_PATH, BACKUP_PATH)
	DirAccess.rename_absolute(TEMP_PATH, SAVE_PATH)

func load_state() -> void:
	var loaded = read_state(SAVE_PATH)
	if not loaded is Dictionary: loaded = read_state(BACKUP_PATH)
	if loaded is Dictionary:
		if loaded.has("progress"): progress.merge(loaded.progress, true)
		if loaded.has("settings"): settings.merge(loaded.settings, true)
	progress.version = SAVE_VERSION

func read_state(path: String):
	if not FileAccess.file_exists(path): return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return null
	return JSON.parse_string(file.get_as_text())

func apply_settings() -> void:
	set_bus("Master", float(settings.master_volume))
	set_bus("Music", float(settings.music_volume))
	set_bus("SFX", float(settings.sfx_volume))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)

func set_bus(bus_name: String, linear: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index >= 0: AudioServer.set_bus_volume_db(index, linear_to_db(clampf(linear, 0.001, 1.0)))
