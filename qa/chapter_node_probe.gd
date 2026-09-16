extends Node
func _ready() -> void:
	print("PROBE_START")
	for chapter_id in range(1, 5):
		var environment := ChapterEnvironment.new()
		environment.setup(chapter_id)
		add_child(environment)
		print("PROBE_CHAPTER_%d" % chapter_id)
		environment.queue_free()
	print("PROBE_PASS")
	get_tree().quit(0)
