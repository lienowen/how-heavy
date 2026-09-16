extends Node
const ProductionWorld = preload("res://scripts/world_production_mechanics.gd")
func _ready() -> void: call_deferred("run_suite")
func run_suite() -> void:
	var failures: Array[String] = []
	var checks := 0
	for room_id: int in range(1, 25):
		Game.current_level = room_id
		var world = ProductionWorld.new()
		add_child(world)
		await get_tree().process_frame
		world.set_process(false)
		world.player.fall_reported = true
		for child in world.get_children():
			if not child is ProductionPressureGate: continue
			checks += 1
			world.player.controls_enabled = true
			world.player.weight = child.threshold
			world.player.global_position = child.plate.global_position - Vector2(0, 75)
			world.player.velocity = Vector2.ZERO
			var opened := false
			for frame: int in range(60):
				await get_tree().physics_frame
				if child.opened:
					opened = true
					break
			if not opened or not child.gate_collision.disabled:
				failures.append("room %02d threshold %d landing trigger" % [room_id, child.threshold])
		world.queue_free()
		await get_tree().process_frame
	if checks != 27: failures.append("coverage expected 27 got %d" % checks)
	if failures.is_empty(): print("QA_PASS gates: 27 real falling-contact threshold openings")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)
