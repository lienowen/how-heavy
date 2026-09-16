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
		failures.append("room 01 heavy gate is missing")
	else:
		world.player.restore(gate.plate.global_position - Vector2(0, 75), 2)
		for frame: int in range(60): await get_tree().physics_frame
		if gate.opened: failures.append("Light incorrectly opens the heavy gate")
		world.player.restore(gate.plate.global_position - Vector2(0, 75), 6)
		for frame: int in range(60): await get_tree().physics_frame
		if gate.opened: failures.append("Balanced incorrectly opens the heavy gate")
		world.player.restore(gate.plate.global_position - Vector2(0, 75), 10)
		for frame: int in range(60):
			await get_tree().physics_frame
			if gate.opened: break
		if not gate.opened or not gate.gate_collision.disabled:
			failures.append("Heavy did not open and disable the gate")
		if world.active_wind_force(gate.plate.global_position.x) <= 0.0:
			failures.append("heavy plate is not staged inside the wind corridor")
	if failures.is_empty(): print("QA_PASS room 01 heavy chain: only weight 10 opens the gate inside the headwind")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)
