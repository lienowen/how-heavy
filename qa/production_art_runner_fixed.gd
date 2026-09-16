extends Node
const ProductionWorld = preload("res://scripts/world_production_art_fixed.gd")
func _ready() -> void: call_deferred("run_suite")
func run_suite() -> void:
	var failures: Array[String] = []
	Game.current_level = 1
	var world = ProductionWorld.new()
	add_child(world)
	await get_tree().process_frame
	await get_tree().physics_frame
	if world.production_background == null: failures.append("production background missing")
	if not world.player is ProductionBearer: failures.append("production player missing")
	if world.find_children("*", "CharacterBody2D", true, false).size() != 1: failures.append("player count")
	var bg_file := FileAccess.open("res://art/production/measure-hall-background-v1.png", FileAccess.READ)
	var player_file := FileAccess.open("res://art/production/bearer-weight-states-v1.png", FileAccess.READ)
	if bg_file == null or bg_file.get_length() < 1000000: failures.append("background source invalid")
	if player_file == null or player_file.get_length() < 1000000: failures.append("player source invalid")
	if failures.is_empty(): print("QA_PASS production art: layered background, authored three-state Bearer, one runtime player")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)

