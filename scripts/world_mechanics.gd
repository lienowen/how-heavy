extends "res://scripts/world_campaign.gd"

const PressureGateType = preload("res://mechanics/pressure_gate.gd")
const MovingPlatformType = preload("res://mechanics/moving_platform.gd")
const SpringPadType = preload("res://mechanics/spring_pad.gd")

func build_level() -> void:
	super()
	var chapter := Campaign.chapter_for_level(level_id)
	var variant := (level_id - 1) % 6
	if chapter >= 2:
		add_pressure_gate(Vector2(1940, 650), Vector2(2230, 555), 9 if variant % 2 == 0 else 6)
	if chapter >= 3:
		add_moving_platform(Vector2(2400, 610), Vector2(260, -90), 3.4 + variant * 0.12, variant * 0.35)
		if variant >= 2: add_spring(Vector2(2860, 635), 760.0)
	if chapter == 4:
		add_pressure_gate(Vector2(2720, 540), Vector2(3090, 535), 10)
		add_moving_platform(Vector2(760, 610), Vector2(220, -130), 3.0, variant * 0.4)

func add_pressure_gate(plate_at: Vector2, gate_at: Vector2, threshold: int) -> void:
	var mechanic: PressureGate = PressureGateType.new()
	mechanic.setup(plate_at, gate_at, threshold)
	add_child(mechanic)

func add_moving_platform(at: Vector2, travel: Vector2, period: float, phase: float) -> void:
	var mechanic: WeightMovingPlatform = MovingPlatformType.new()
	mechanic.setup(at, travel, period, phase)
	add_child(mechanic)

func add_spring(at: Vector2, power: float) -> void:
	var mechanic: WeightSpringPad = SpringPadType.new()
	mechanic.setup(at, power)
	add_child(mechanic)
