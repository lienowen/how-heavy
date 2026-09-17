extends "res://scripts/world_production_mechanics.gd"
const PerformancePlayerType = preload("res://scripts/player_performance.gd")

func spawn_player() -> void:
	player = PerformancePlayerType.new()
	player.position = START
	add_child(player)
	player.weight_changed.connect(update_weight)
	player.exchanged.connect(func(): exchanges += 1)
	player.fell_out.connect(on_fell)
	player.heavy_impact.connect(on_impact)
	var camera := Camera2D.new()
	camera.position = Vector2(85, -235)
	camera.zoom = Vector2(1.08, 1.08)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7
	camera.limit_left = 0
	camera.limit_right = 3550
	camera.limit_top = 0
	camera.limit_bottom = 940
	player.add_child(camera)
	update_weight(player.weight)

func on_fell() -> void:
	if player is PerformanceBearer: player.play_failure()
	await super()

func on_impact(at: Vector2, speed: float) -> void:
	super(at, speed)
	if player is PerformanceBearer: player.play_impact()

func complete_slice() -> void:
	if player is PerformanceBearer: player.play_victory()
	super()
