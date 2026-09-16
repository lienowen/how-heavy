extends "res://scripts/app_polished.gd"

const FinaleWorld = preload("res://scripts/world_finale.gd")

func show_title() -> void:
	super()
	var version := make_label("v0.14.0  |  WINDOWS  |  CONTROLLER SUPPORTED", 12, Color("879295"))
	version.position = Vector2(900, 682)
	screen.add_child(version)
	if str(Game.progress.ending) != "":
		var mark := make_label("THE HALL REMEMBERS: %s" % str(Game.progress.ending).to_upper(), 13, Color("d7b85a"))
		mark.position = Vector2(875, 45)
		screen.add_child(mark)

func launch_game() -> void:
	launch_level(int(Game.current_level))

func launch_level(level_id: int) -> void:
	Game.current_level = clampi(level_id, 1, 24)
	if is_instance_valid(screen): screen.queue_free()
	screen = null
	world = FinaleWorld.new()
	world.return_to_menu.connect(show_chapters)
	world.next_level_requested.connect(launch_level)
	add_child(world)
