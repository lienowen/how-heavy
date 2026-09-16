extends Node

const ReleaseWorld = preload("res://scripts/world_release_candidate.gd")

func _ready() -> void:
	call_deferred("run")

func run() -> void:
	Game.current_level = 1
	var world := ReleaseWorld.new()
	add_child(world)
	await get_tree().process_frame
	var failures: Array[String] = []
	if world.active_wind_force(780.0) != 0.0:
		failures.append("wind begins before the marked corridor")
	if world.active_wind_force(900.0) != 520.0:
		failures.append("room 01 headwind is missing")
	var light_drag := 520.0 * ((12.0 - 2.0) / 10.0)
	var balanced_drag := 520.0 * ((12.0 - 6.0) / 10.0)
	var heavy_drag := 520.0 * ((12.0 - 10.0) / 10.0)
	if not (light_drag > balanced_drag and balanced_drag > heavy_drag):
		failures.append("weight-dependent wind response is not ordered")
	if light_drag < balanced_drag * 1.5:
		failures.append("Light wind trade-off is not perceptible enough")
	if failures.is_empty():
		print("QA_PASS room 01 wind: visible corridor and weight-scaled headwind trade-off")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)
