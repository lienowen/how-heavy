extends "res://systems/achievement_service.gd"
const BACKUP_PATH := "user://achievements.backup.json"

func save_state() -> void:
	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null: return
	file.store_string(JSON.stringify({"version":1,"backend":backend,"unlocked":unlocked}, "  "))
	file.close()
	if FileAccess.file_exists(SAVE_PATH):
		if FileAccess.file_exists(BACKUP_PATH): DirAccess.remove_absolute(BACKUP_PATH)
		DirAccess.rename_absolute(SAVE_PATH, BACKUP_PATH)
	DirAccess.rename_absolute(TEMP_PATH, SAVE_PATH)

func load_state() -> void:
	var parsed = read_achievement_file(SAVE_PATH)
	if not valid_achievement_payload(parsed): parsed = read_achievement_file(BACKUP_PATH)
	apply_achievement_payload(parsed)

func read_achievement_file(path: String):
	if not FileAccess.file_exists(path): return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return null
	return JSON.parse_string(file.get_as_text())

func valid_achievement_payload(value) -> bool:
	return value is Dictionary and value.get("unlocked", null) is Dictionary

func apply_achievement_payload(value) -> void:
	unlocked.clear()
	if not valid_achievement_payload(value): return
	for api_name in value.unlocked:
		if api_name in KNOWN_IDS: unlocked[api_name] = value.unlocked[api_name]

