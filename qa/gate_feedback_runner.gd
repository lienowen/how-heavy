extends Node

const ReleaseWorld = preload("res://scripts/world_release_candidate.gd")

func _ready() -> void:
	call_deferred("run")

func run() -> void:
	Game.current_level = 1
	var world := ReleaseWorld.new()
	add_child(world)
	await get_tree().process_frame
	var gate: ProductionPressureGate
	for child in world.get_children():
		if child is ProductionPressureGate:
			gate = child
			break
	var failures: Array[String] = []
	if gate == null:
		failures.append("missing room 01 gate")
	else:
		world.player.restore(gate.plate.global_position - Vector2(0, 75), 10)
		for frame: int in range(60):
			await get_tree().physics_frame
			if gate.opened: break
		await get_tree().process_frame
		if int(world.feedback.event_counts.gate) != 1:
			failures.append("gate visual feedback did not fire exactly once")
		if not world.audio_director.sounds.has("gate_open"):
			failures.append("gate opening sound is missing")
		for frame: int in range(30): await get_tree().physics_frame
		if int(world.feedback.event_counts.gate) != 1:
			failures.append("gate feedback repeated while plate remained pressed")
	if failures.is_empty(): print("QA_PASS gate feedback: one-shot visual, sound and camera event")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)
