extends Node
const ReleaseWorld = preload("res://scripts/world_release_candidate.gd")
func _ready() -> void: call_deferred("run_suite")
func run_suite() -> void:
	var failures: Array[String] = []
	var saved_progress: Dictionary = Game.progress.duplicate(true)
	var saved_settings: Dictionary = Game.settings.duplicate(true)
	var saved_achievements: Dictionary = Achievements.unlocked.duplicate(true)
	Game.progress.completed = {}
	Game.progress.best_times = {}
	Game.progress.unlocked_level = 1
	Game.progress.ending = ""
	Achievements.unlocked.clear()
	for room_id: int in range(1, 25):
		Game.complete_level(room_id, 30.0 + room_id, room_id % 4, room_id % 3)
		if not Game.progress.completed.has(str(room_id)): failures.append("room %02d completion" % room_id)
		if int(Game.progress.unlocked_level) != mini(room_id + 1, 24): failures.append("room %02d unlock" % room_id)
	if Game.progress.completed.size() != 24: failures.append("24-room completion count")
	Game.current_level = 24
	var world = ReleaseWorld.new()
	add_child(world)
	await get_tree().process_frame
	world.complete_slice()
	await get_tree().process_frame
	if world.ending_layer == null or not world.finished: failures.append("ending choice not shown")
	world.choose_ending("release")
	await get_tree().process_frame
	if str(Game.progress.ending) != "release" or not Achievements.is_unlocked("RELEASED"): failures.append("release ending")
	world.choose_ending("carry")
	await get_tree().process_frame
	if str(Game.progress.ending) != "carry" or not Achievements.is_unlocked("CARRIED"): failures.append("carry ending")
	world.queue_free()
	await get_tree().process_frame
	Game.progress = saved_progress
	Game.settings = saved_settings
	Achievements.unlocked = saved_achievements
	Game.save_state()
	Achievements.save_state()
	if failures.is_empty(): print("QA_PASS release flow: 24 progress steps, final choice, release and carry endings, ending achievements")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)
