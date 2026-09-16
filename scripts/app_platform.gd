extends "res://scripts/app_finale.gd"

const PlatformWorld = preload("res://scripts/world_web_compatible.gd")
var web_audio_armed := false

func _ready() -> void:
	web_audio_armed = not OS.has_feature("web")
	super()

func launch_game() -> void:
	launch_level(int(Game.current_level))

func launch_level(level_id: int) -> void:
	Game.current_level = clampi(level_id, 1, 24)
	if is_instance_valid(screen): screen.queue_free()
	screen = null
	world = PlatformWorld.new()
	world.return_to_menu.connect(show_chapters)
	world.next_level_requested.connect(launch_level)
	add_child(world)

func _input(event: InputEvent) -> void:
	if OS.has_feature("web") and not web_audio_armed and (event is InputEventKey or event is InputEventMouseButton or event is InputEventScreenTouch):
		web_audio_armed = true
		var master := AudioServer.get_bus_index("Master")
		if master >= 0: AudioServer.set_bus_mute(master, false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		Game.save_state()
		if is_instance_valid(world) and world.has_method("set_paused") and not world.finished:
			world.set_paused(true)
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		Game.save_state()
