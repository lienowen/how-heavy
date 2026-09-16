extends Node
func _ready() -> void: call_deferred("run")
func fail(message: String) -> void: push_error("QA_FAIL " + message); get_tree().quit(1)
func run() -> void:
	var app_script = load("res://scripts/app_platform.gd")
	var world_script = load("res://scripts/world_web_compatible.gd")
	if app_script == null or world_script == null: return fail("platform scripts failed to load")
	Game.current_level = 1
	var world = world_script.new()
	add_child(world)
	await get_tree().process_frame
	if world.player == null: return fail("shared gameplay failed under platform layer")
	if not world.has_method("build_touch_controls"): return fail("touch control adapter missing")
	Game.save_state()
	if not FileAccess.file_exists("user://campaign.json"): return fail("portable user save failed")
	print("QA_PASS web compatibility: shared gameplay, portable save path, touch adapter, focus lifecycle script")
	get_tree().quit(0)
