extends "res://scripts/app.gd"

const ReleaseWorld = preload("res://scripts/world_release.gd")

func launch_game() -> void:
	if is_instance_valid(screen):
		screen.queue_free()
		screen = null
	world = ReleaseWorld.new()
	world.return_to_menu.connect(show_title)
	add_child(world)
