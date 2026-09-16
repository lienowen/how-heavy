extends Node
const ChapterWorld = preload("res://scripts/world_chapter_environment.gd")

func _ready() -> void: call_deferred("run_suite")

func run_suite() -> void:
	var failures: Array[String] = []
	var signatures: Array[String] = []
	for room_id: int in [1, 7, 13, 19]:
		Game.current_level = room_id
		var world = ChapterWorld.new()
		add_child(world)
		await get_tree().process_frame
		await get_tree().physics_frame
		var expected: int = Campaign.chapter_for_level(room_id)
		if not is_instance_valid(world.chapter_environment): failures.append("chapter %d treatment missing" % expected)
		elif world.chapter_environment.chapter != expected: failures.append("chapter %d treatment mismatch" % expected)
		else:
			var colors: Dictionary = world.chapter_environment.palette()
			signatures.append("%s:%s:%d" % [colors.accent.to_html(), colors.secondary.to_html(), world.chapter_environment.motif_count])
		remove_child(world)
		world.free()
	if signatures.size() != 4: failures.append("chapter signatures missing")
	else:
		var unique: Dictionary = {}
		for signature: String in signatures: unique[signature] = true
		if unique.size() != 4: failures.append("chapter treatments are not distinct")
	if failures.is_empty(): print("QA_PASS chapter art: four distinct palettes, spatial motifs, motion systems and atmosphere profiles")
	else:
		for failure: String in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)
