extends Node
const CommercialWorld = preload("res://scripts/world_commercial_ui.gd")

func _ready() -> void: call_deferred("run_suite")

func run_suite() -> void:
	var failures: Array[String] = []
	Game.current_level = 1
	var world = CommercialWorld.new()
	add_child(world)
	await get_tree().process_frame
	await get_tree().physics_frame
	if not is_instance_valid(world.weight_dial): failures.append("weight dial missing")
	if not is_instance_valid(world.ui_root): failures.append("responsive ui root missing")
	elif world.ui_root.theme == null: failures.append("production theme missing")
	if not is_instance_valid(world.hint_label): failures.append("hint missing")
	if not is_instance_valid(world.result_panel): failures.append("result panel missing")
	world.update_weight(10)
	if world.weight_dial.weight != 10: failures.append("dial does not track weight")
	if "HEAVY" not in world.weight_label.text: failures.append("weight state copy missing")
	if failures.is_empty(): print("QA_PASS commercial UI: custom theme, responsive HUD, ring weight dial, contextual controls")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)

