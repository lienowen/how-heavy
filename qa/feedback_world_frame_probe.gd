extends Node
func _ready() -> void:
	Game.current_level = 1
	var world := preload("res://scripts/world_feedback_sequences.gd").new()
	add_child(world)
	print("FW_FRAME_WAIT")
	await get_tree().process_frame
	print("FW_FRAME_PASS")
	get_tree().quit(0)
