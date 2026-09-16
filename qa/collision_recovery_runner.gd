extends Node
const ReleaseWorld = preload("res://scripts/world_release_candidate.gd")
func _ready() -> void: call_deferred("run_suite")
func run_suite() -> void:
	var failures: Array[String] = []
	var landing_checks := 0
	var gate_collision_checks := 0
	var recovery_checks := 0
	var old_shake: bool = bool(Game.settings.screen_shake)
	Game.settings.screen_shake = false
	for room_id: int in range(1, 25):
		Game.current_level = room_id
		var world = ReleaseWorld.new()
		add_child(world)
		await get_tree().process_frame
		world.set_process(false)
		world.player.fall_reported = true
		var platforms: Array = world.room_layout.platforms
		for platform_index: int in [0, platforms.size() - 1]:
			var platform: Array = platforms[platform_index]
			var center_x: float = float(platform[0]) + float(platform[2]) * 0.5
			var top_y: float = float(platform[1])
			world.player.restore(Vector2(center_x, top_y - 80.0), 6)
			world.player.fall_reported = true
			var landed := false
			for frame: int in range(120):
				await get_tree().physics_frame
				if world.player.is_on_floor():
					landed = true
					break
			landing_checks += 1
			if not landed or world.player.global_position.y >= 940.0:
				failures.append("room %02d platform %d landing" % [room_id, platform_index])
		for child in world.get_children():
			if child is ProductionPressureGate:
				gate_collision_checks += 1
				if child.opened or child.gate_collision == null or child.gate_collision.disabled or child.gate_collision.shape == null:
					failures.append("room %02d closed gate collision" % room_id)
		var recovery_position: Vector2 = Vector2(float(platforms[0][0]) + 80.0, float(platforms[0][1]))
		world.checkpoint = recovery_position
		world.checkpoint_weight = 6
		world.player.global_position = Vector2(-240.0, 1100.0)
		world.player.fall_reported = true
		await world.on_fell()
		recovery_checks += 1
		if world.player.global_position.distance_to(recovery_position) > 2.0 or not world.player.controls_enabled:
			failures.append("room %02d out-of-bounds recovery" % room_id)
		world.queue_free()
		await get_tree().process_frame
	Game.settings.screen_shake = old_shake
	if landing_checks != 48: failures.append("landing coverage %d" % landing_checks)
	if gate_collision_checks != 27: failures.append("gate collision coverage %d" % gate_collision_checks)
	if recovery_checks != 24: failures.append("recovery coverage %d" % recovery_checks)
	if failures.is_empty(): print("QA_PASS collision recovery: 48 static landings, 27 closed gates, 24 out-of-bounds restores")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)
