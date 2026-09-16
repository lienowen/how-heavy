extends Node
func _ready() -> void:
	print("FW_START")
	Game.current_level = 1
	var world := preload("res://scripts/world_feedback_sequences.gd").new()
	print("FW_CREATED")
	add_child(world)
	print("FW_ADDED")
	get_tree().quit(0)
