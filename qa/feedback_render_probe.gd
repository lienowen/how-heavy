extends Node
func _ready() -> void:
	var feedback := ProductionFeedback.new()
	add_child(feedback)
	for sequence in range(1, 6):
		feedback.start(sequence as ProductionFeedback.Sequence, 1.0, Vector2(640, 350))
		print("RENDER_SEQUENCE_%d_START" % sequence)
		await get_tree().process_frame
		print("RENDER_SEQUENCE_%d_PASS" % sequence)
	print("RENDER_PROBE_PASS")
	get_tree().quit(0)
