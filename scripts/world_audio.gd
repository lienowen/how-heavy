extends "res://scripts/world_mechanics.gd"

const AudioDirectorType = preload("res://audio/audio_director.gd")
var audio_director: GameAudioDirector
var last_checkpoint_stage := 0

func _ready() -> void:
	super()
	audio_director = AudioDirectorType.new()
	add_child(audio_director)
	player.exchanged.connect(on_trade_sound)

func on_trade_sound() -> void:
	audio_director.play_named("trade_light" if player.weight <= 3 else "trade_heavy")

func update_checkpoint() -> void:
	var before := checkpoint_stage
	super()
	if checkpoint_stage > before and is_instance_valid(audio_director): audio_director.play_named("checkpoint")

func on_impact(at: Vector2, speed: float) -> void:
	var before := broken
	super(at, speed)
	if not before and broken and is_instance_valid(audio_director): audio_director.play_named("break_floor")

func on_fell() -> void:
	if not respawning and not finished and is_instance_valid(audio_director): audio_director.play_named("failure")
	await super()

func complete_slice() -> void:
	super()
	if is_instance_valid(audio_director): audio_director.play_named("complete")
