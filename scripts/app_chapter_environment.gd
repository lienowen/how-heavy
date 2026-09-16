extends "res://scripts/app_commercial_ui.gd"
const ChapterWorld = preload("res://scripts/world_chapter_environment.gd")

func launch_level(level_id: int) -> void:
	Game.current_level = clampi(level_id, 1, 24)
	if is_instance_valid(screen): screen.queue_free()
	screen = null
	world = ChapterWorld.new()
	world.return_to_menu.connect(show_chapters)
	world.next_level_requested.connect(launch_level)
	add_child(world)
	CrazyGamesBridge.gameplay_start()

