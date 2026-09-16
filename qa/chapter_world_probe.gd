extends Node
func _ready() -> void:
	print("WORLD_PROBE_START")
	Game.current_level = 1
	var world := preload("res://scripts/world_chapter_environment.gd").new()
	print("WORLD_CREATED")
	add_child(world)
	print("WORLD_ADDED")
	await get_tree().process_frame
	print("WORLD_FRAME")
	get_tree().quit(0)
