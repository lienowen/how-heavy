extends "res://scripts/world_chapter_environment.gd"
const FeedbackType = preload("res://scripts/production_feedback.gd")

var feedback: ProductionFeedback
var feedback_layer: CanvasLayer
var camera: Camera2D

func _ready() -> void:
	super()
	feedback_layer = CanvasLayer.new()
	feedback_layer.layer = 50
	add_child(feedback_layer)
	feedback = FeedbackType.new()
	feedback_layer.add_child(feedback)
	camera = player.get_node_or_null("Camera2D") as Camera2D
	player.exchanged.connect(on_exchange_sequence)

func screen_position(world_position: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform() * world_position

func on_exchange_sequence() -> void:
	feedback.play_exchange(screen_position(player.global_position + Vector2(0, -45)))
	shake_camera(7.0, 0.22)

func update_checkpoint() -> void:
	var before := checkpoint_stage
	super()
	if checkpoint_stage > before and is_instance_valid(feedback):
		feedback.play_checkpoint(screen_position(player.global_position + Vector2(0, -55)))

func on_impact(at: Vector2, speed: float) -> void:
	var was_broken := broken
	super(at, speed)
	if not was_broken and broken and is_instance_valid(feedback):
		feedback.play_impact(screen_position(at))
		shake_camera(clampf(speed / 55.0, 10.0, 18.0), 0.34)

func on_fell() -> void:
	if not respawning and not finished and is_instance_valid(feedback):
		feedback.play_failure(screen_position(player.global_position))
		shake_camera(9.0, 0.28)
	await super()

func complete_slice() -> void:
	if is_instance_valid(feedback): feedback.play_complete(Vector2(640, 350))
	shake_camera(5.0, 0.4)
	super()

func shake_camera(strength: float, seconds: float) -> void:
	if not bool(Game.settings.screen_shake) or not is_instance_valid(camera): return
	var tween := create_tween()
	var steps := maxi(2, int(seconds / 0.045))
	for i in range(steps):
		var decay := 1.0 - float(i) / steps
		var offset := Vector2(sin(i * 2.7), cos(i * 4.1)) * strength * decay
		tween.tween_property(camera, "offset", offset, seconds / steps)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)

