extends Node
signal achievement_unlocked(api_name: String)
const SAVE_PATH := "user://achievements.json"
const TEMP_PATH := "user://achievements.tmp.json"
const KNOWN_IDS := ["FIRST_TRADE", "LIGHT_STEP", "HOLD_FAST", "BREAK_THE_MEASURE", "CHAPTER_MEASURED", "TRUE_BALANCE", "CARRIED_FORWARD", "NO_FALLS", "NO_TRADE", "THE_LAST_EXCHANGE", "RELEASED", "CARRIED"]
var unlocked: Dictionary = {}
var backend := "offline"

func _ready() -> void: load_state()

func unlock(api_name: String) -> bool:
	if api_name not in KNOWN_IDS or unlocked.has(api_name): return false
	unlocked[api_name] = Time.get_unix_time_from_system()
	save_state()
	achievement_unlocked.emit(api_name)
	return true

func is_unlocked(api_name: String) -> bool: return unlocked.has(api_name)

func save_state() -> void:
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null: return
	file.store_string(JSON.stringify({"version":1,"backend":backend,"unlocked":unlocked}, "  "))
	file.close()
	if FileAccess.file_exists(SAVE_PATH): DirAccess.remove_absolute(SAVE_PATH)
	DirAccess.rename_absolute(TEMP_PATH, SAVE_PATH)

func load_state() -> void:
	if not FileAccess.file_exists(SAVE_PATH): return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null: return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary and parsed.get("unlocked", {}) is Dictionary:
		for api_name in parsed.unlocked:
			if api_name in KNOWN_IDS: unlocked[api_name] = parsed.unlocked[api_name]

