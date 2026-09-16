extends "res://scripts/app_accessible.gd"

const PolishedWorld = preload("res://scripts/world_polished.gd")

func show_title() -> void:
	super()
	call_deferred("focus_first_button")

func show_chapters() -> void:
	super()
	call_deferred("focus_first_button")

func show_levels(chapter_id: int) -> void:
	super(chapter_id)
	call_deferred("focus_first_button")

func show_settings() -> void:
	super()
	call_deferred("focus_first_button")

func focus_first_button() -> void:
	if not is_instance_valid(screen): return
	for node in screen.find_children("*", "Button", true, false):
		if not node.disabled:
			node.grab_focus()
			return

func launch_game() -> void:
	launch_level(int(Game.current_level))

func launch_level(level_id: int) -> void:
	Game.current_level = clampi(level_id, 1, 24)
	if is_instance_valid(screen): screen.queue_free()
	screen = null
	world = PolishedWorld.new()
	world.return_to_menu.connect(show_chapters)
	world.next_level_requested.connect(launch_level)
	add_child(world)
