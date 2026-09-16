extends Node
const PlayerType = preload("res://scripts/player_performance.gd")

func _ready() -> void: call_deferred("run_suite")

func run_suite() -> void:
	var failures: Array[String] = []
	var player: PerformanceBearer = PlayerType.new()
	add_child(player)
	await get_tree().process_frame
	var expected := ["idle", "walk", "takeoff", "rise", "fall", "land", "exchange", "impact", "failure", "victory"]
	for index in range(expected.size()):
		player.set_pose(index as PerformanceBearer.Pose)
		if player.animation_name() != expected[index]: failures.append("pose %d name mismatch" % index)
	player.play_exchange()
	if player.animation_name() != "exchange" or player.forced_pose_time <= 0.0: failures.append("exchange event animation")
	player.play_impact()
	if player.animation_name() != "impact": failures.append("impact event animation")
	player.play_failure()
	if player.animation_name() != "failure": failures.append("failure event animation")
	player.play_victory()
	if player.animation_name() != "victory": failures.append("victory event animation")
	if failures.is_empty(): print("QA_PASS animation coverage: idle, walk, takeoff, rise, fall, land, exchange, impact, failure and victory")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)

