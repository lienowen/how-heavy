extends "res://scripts/app_platform.gd"
const CrazyWorld = preload("res://scripts/world_crazygames.gd")

func show_title() -> void:
	CrazyGamesBridge.gameplay_stop()
	super()

func show_chapters() -> void:
	CrazyGamesBridge.gameplay_stop()
	super()

func show_settings() -> void:
	super()
	if OS.has_feature("web"):
		for node in screen.find_children("*", "CheckButton", true, false):
			if node.text == "Fullscreen": node.queue_free()

func launch_level(level_id: int) -> void:
	Game.current_level = clampi(level_id, 1, 24)
	if is_instance_valid(screen): screen.queue_free()
	screen = null
	world = CrazyWorld.new()
	world.return_to_menu.connect(show_chapters)
	world.next_level_requested.connect(launch_level)
	add_child(world)
	CrazyGamesBridge.gameplay_start()

