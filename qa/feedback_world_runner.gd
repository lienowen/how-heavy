extends Node
const FeedbackWorld = preload("res://scripts/world_feedback_sequences.gd")

func _ready() -> void: call_deferred("run_suite")

func run_suite() -> void:
	Game.current_level = 1
	var world = FeedbackWorld.new()
	add_child(world)
	await get_tree().process_frame
	var failures: Array[String] = []
	if not is_instance_valid(world.feedback): failures.append("feedback overlay missing")
	if not is_instance_valid(world.camera): failures.append("camera binding missing")
	world.on_exchange_sequence()
	if int(world.feedback.event_counts.exchange) != 1: failures.append("exchange wiring")
	var old_shake := bool(Game.settings.screen_shake)
	Game.settings.screen_shake = false
	world.camera.offset = Vector2.ZERO
	world.shake_camera(20.0, 0.2)
	if world.camera.offset != Vector2.ZERO: failures.append("screen shake accessibility")
	Game.settings.screen_shake = old_shake
	if failures.is_empty(): print("QA_PASS feedback world: overlay, event wiring, camera and accessibility guard")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)

