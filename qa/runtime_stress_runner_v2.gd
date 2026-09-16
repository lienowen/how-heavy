extends Node

const WorldType = preload("res://scripts/world_feedback_sequences.gd")
const TEST_WEIGHTS: Array[int] = [2, 6, 10]

func _ready() -> void:
	call_deferred("run_suite")

func run_suite() -> void:
	var failures: Array[String] = []
	var old_shake: bool = bool(Game.settings.screen_shake)
	Game.settings.screen_shake = false
	Game.current_level = 12
	var world = WorldType.new()
	add_child(world)
	await get_tree().process_frame
	for cycle: int in range(100):
		var weight: int = TEST_WEIGHTS[cycle % 3]
		var target := Vector2(100.0 + cycle % 4 * 120.0, 620.0)
		world.player.restore(target, weight)
		world.on_exchange_sequence()
		world.feedback.play_checkpoint(Vector2(640, 350))
		world.set_paused(true)
		world.set_paused(false)
		if world.player.weight != weight: failures.append("cycle %d weight" % cycle)
		if world.player.global_position != target: failures.append("cycle %d position" % cycle)
		if get_tree().paused: failures.append("cycle %d pause leak" % cycle)
		if not world.player.controls_enabled: failures.append("cycle %d controls" % cycle)
	Game.settings.screen_shake = old_shake
	if int(world.feedback.event_counts.exchange) != 100: failures.append("exchange event count")
	if int(world.feedback.event_counts.checkpoint) != 100: failures.append("checkpoint event count")
	if failures.is_empty(): print("QA_PASS runtime stress: 100 restore/exchange/checkpoint/pause/resume cycles")
	else:
		for failure in failures: push_error(failure)
	world.queue_free()
	await get_tree().process_frame
	get_tree().quit(0 if failures.is_empty() else 1)
