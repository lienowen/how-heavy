extends "res://scripts/world_commercial_ui.gd"

const VesselType = preload("res://mechanics/production_weight_vessel.gd")
const GateType = preload("res://mechanics/production_pressure_gate.gd")
const SpringType = preload("res://mechanics/production_spring_pad.gd")
const MoverType = preload("res://mechanics/production_moving_platform.gd")

func make_stone(at: Vector2, value: int) -> void:
	var item: ProductionWeightVessel = VesselType.new()
	item.setup(at, value)
	add_child(item)

func add_pressure_gate(plate_at: Vector2, gate_at: Vector2, threshold: int) -> void:
	var mechanic: ProductionPressureGate = GateType.new()
	mechanic.setup(plate_at, gate_at, threshold)
	add_child(mechanic)

func add_moving_platform(at: Vector2, travel: Vector2, period: float, phase: float) -> void:
	var mechanic: ProductionMovingPlatform = MoverType.new()
	mechanic.setup(at, travel, period, phase)
	add_child(mechanic)

func add_spring(at: Vector2, power: float) -> void:
	var mechanic: ProductionSpringPad = SpringType.new()
	mechanic.setup(at, power)
	add_child(mechanic)

func _draw() -> void:
	super()
	for zone in wind_zones:
		var start := float(zone[0])
		var finish := float(zone[1])
		var direction := signf(float(zone[2]))
		for x in range(int(start) + 65, int(finish) - 30, 130):
			var base := Vector2(x, 420 + posmod(x, 170))
			draw_arc(base, 15, -0.8 if direction > 0 else 2.35, 0.8 if direction > 0 else 3.95, 18, Color(0.46, 0.79, 0.81, 0.52), 2)
			draw_line(base + Vector2(-18 * direction, 0), base + Vector2(18 * direction, 0), Color(0.46, 0.79, 0.81, 0.34), 2)
	if needs_break and not broken:
		var fragile_item = room_layout.fragile[0]
		var left := float(fragile_item[0])
		var top := float(fragile_item[1])
		var width := float(fragile_item[2])
		for x in range(int(left) + 24, int(left + width) - 12, 42):
			draw_polyline(PackedVector2Array([Vector2(x, top + 3), Vector2(x + 9, top + 10), Vector2(x + 2, top + 18)]), Color("e0c06b"), 2)

