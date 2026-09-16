extends "res://scripts/app_campaign.gd"

const MechanicsWorld = preload("res://scripts/world_mechanics.gd")

func launch_game() -> void:
	launch_level(int(Game.current_level))

func launch_level(level_id: int) -> void:
	Game.current_level = clampi(level_id, 1, 24)
	if is_instance_valid(screen): screen.queue_free()
	screen = null
	world = MechanicsWorld.new()
	world.return_to_menu.connect(show_title)
	world.next_level_requested.connect(launch_level)
	add_child(world)
