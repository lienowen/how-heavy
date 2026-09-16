extends "res://scripts/world_feedback_sequences.gd"

const AtmosphereType = preload("res://scripts/weight_atmosphere.gd")
var weight_atmosphere: WeightAtmosphere

func _ready() -> void:
	super()
	var layer := CanvasLayer.new()
	layer.layer = 35
	add_child(layer)
	weight_atmosphere = AtmosphereType.new()
	layer.add_child(weight_atmosphere)
	if is_instance_valid(audio_director):
		audio_director.sounds.gate_open = audio_director.make_tone([92.0, 116.0, 174.0], 0.52, 0.52)
		audio_director.sounds.heavy_land = audio_director.make_noise_hit(0.3, 0.5)
	for child in get_children():
		if child is ProductionPressureGate: child.opened_gate.connect(on_gate_opened)

func _process(delta: float) -> void:
	super(delta)
	if not is_instance_valid(player) or not is_instance_valid(weight_atmosphere): return
	var target := player.nearby as ReleaseStone
	var player_screen := screen_position(player.global_position + Vector2(0, -42))
	var target_screen := screen_position(target.global_position) if target != null else Vector2.ZERO
	weight_atmosphere.set_state(player.weight, player_screen, target_screen, target.weight if target != null else -1, active_wind_force(player.global_position.x))

func on_gate_opened(at: Vector2) -> void:
	var focus := screen_position(at)
	if is_instance_valid(feedback): feedback.play_gate(focus)
	if is_instance_valid(audio_director): audio_director.play_named("gate_open")
	shake_camera(11.0, 0.34)

func update_interaction() -> void:
	if not is_instance_valid(player): return
	var nearest: ReleaseStone
	var same_weight_near := false
	var best := 145.0
	for node in get_tree().get_nodes_in_group("release_stones"):
		var item := node as ReleaseStone
		if not is_instance_valid(item): continue
		var distance := player.global_position.distance_to(item.global_position)
		if distance >= best: continue
		if item.weight == player.weight:
			same_weight_near = true
			continue
		best = distance
		nearest = item
	if player.nearby != nearest:
		if player.nearby != null: player.nearby.active = false
		player.nearby = nearest
	if nearest != null:
		nearest.active = true
		hint_label.text = "E  •  TRADE    CURRENT %d  →  TARGET %d" % [player.weight, nearest.weight]
	elif same_weight_near:
		hint_label.text = "SAME WEIGHT %d  •  FIND A DIFFERENT LOAD" % player.weight
	else:
		hint_label.text = base_hint()

func on_trade_sound() -> void:
	Achievements.unlock("FIRST_TRADE")
	super()

func on_impact(at: Vector2, speed: float) -> void:
	var was_broken: bool = broken
	super(at, speed)
	if not was_broken and broken:
		Achievements.unlock("BREAK_THE_MEASURE")
	else:
		if is_instance_valid(feedback): feedback.play_impact(screen_position(at))
		if is_instance_valid(audio_director): audio_director.play_named("heavy_land")
		shake_camera(clampf(speed / 60.0, 8.0, 13.0), 0.24)

func set_paused(value: bool) -> void:
	if value: CrazyGamesBridge.gameplay_stop()
	else: CrazyGamesBridge.gameplay_start()
	super(value)
func complete_slice() -> void:
	CrazyGamesBridge.gameplay_stop()
	if level_id < 24:
		super()
		return
	if finished: return
	finished = true
	player.controls_enabled = false
	Game.complete_level(level_id, elapsed, exchanges, deaths)
	show_ending_choice()
func choose_ending(choice: String) -> void:
	if choice not in ["release", "carry"]: return
	Achievements.unlock("RELEASED" if choice == "release" else "CARRIED")
	CrazyGamesBridge.happy_time()
	super(choice)
