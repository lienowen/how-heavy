extends "res://scripts/app_platform.gd"
const CommercialWorld = preload("res://scripts/world_commercial.gd")

func launch_level(level_id: int) -> void:
	Game.current_level = clampi(level_id, 1, 24)
	if is_instance_valid(screen): screen.queue_free()
	screen = null
	world = CommercialWorld.new()
	world.return_to_menu.connect(show_chapters)
	world.next_level_requested.connect(launch_level)
	add_child(world)

