extends Node
const FirstWorld = preload("res://scripts/world_first_session.gd")
func _ready() -> void: call_deferred("run_suite")
func run_suite() -> void:
	var failures: Array[String] = []
	Game.current_level = 1
	Game.progress.completed = {}
	Game.progress.unlocked_level = 1
	var world = FirstWorld.new()
	add_child(world)
	await get_tree().process_frame
	if world.level_id != 1: failures.append("first session did not open room 1")
	if not is_instance_valid(world.tutorial_label): failures.append("behavior tutorial missing")
	elif "MOVE" not in world.tutorial_label.text: failures.append("first prompt is not movement")
	if world.find_children("*", "CharacterBody2D", true, false).size() != 1: failures.append("first room player count")
	world.complete_slice()
	await get_tree().process_frame
	if not is_instance_valid(world.next_button): failures.append("next-room CTA missing")
	elif world.next_button.text != "CONTINUE TO ROOM 02": failures.append("next-room CTA copy")
	if failures.is_empty(): print("QA_PASS first session: direct room 1, behavior tutorial, one player, prominent next-room CTA")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)

