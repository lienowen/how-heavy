extends Node

const ReleaseWorld = preload("res://scripts/world_release_candidate.gd")
const LANDING_X := 700.0

func _ready() -> void:
	call_deferred("run")

func run() -> void:
	var light_lands := await attempt(2)
	var balanced_lands := await attempt(6)
	var heavy_lands := await attempt(10)
	if light_lands and not balanced_lands and not heavy_lands:
		print("QA_PASS room 01: only Light clears the teaching gap")
		get_tree().quit(0)
	else:
		push_error("room 01 jump gate incorrect: light=%s balanced=%s heavy=%s" % [light_lands, balanced_lands, heavy_lands])
		get_tree().quit(1)

func attempt(weight: int) -> bool:
	Game.current_level = 1
	var world := ReleaseWorld.new()
	add_child(world)
	await get_tree().process_frame
	world.player.restore(Vector2(350, 620), weight)
	for frame: int in range(30):
		await get_tree().physics_frame
		if world.player.is_on_floor(): break
	var ratio := float(weight - 2) / 8.0
	world.player.velocity.y = -lerpf(800.0, 420.0, ratio)
	Input.action_press("move_right")
	var landed := false
	for frame: int in range(240):
		await get_tree().physics_frame
		if world.player.is_on_floor() and world.player.global_position.x >= LANDING_X:
			landed = true
			break
	Input.action_release("move_right")
	world.queue_free()
	await get_tree().process_frame
	return landed
