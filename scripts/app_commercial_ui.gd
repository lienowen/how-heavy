extends "res://scripts/app_crazygames.gd"
const CommercialWorld = preload("res://scripts/world_commercial_ui.gd")

func _ready() -> void:
	web_audio_armed = not OS.has_feature("web")
	if Game.progress.completed.is_empty() and int(Game.progress.unlocked_level) <= 1: launch_level(1)
	else: show_title()

func clear_view() -> void:
	super()
	screen.theme = ProductionTheme.build()

func launch_level(level_id: int) -> void:
	Game.current_level = clampi(level_id, 1, 24)
	if is_instance_valid(screen): screen.queue_free()
	screen = null
	world = CommercialWorld.new()
	world.return_to_menu.connect(show_chapters)
	world.next_level_requested.connect(launch_level)
	add_child(world)
	CrazyGamesBridge.gameplay_start()

