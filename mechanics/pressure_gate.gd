class_name PressureGate
extends Node2D

signal opened_gate(at: Vector2)

var threshold := 9
var opened := false
var plate: Area2D
var gate: StaticBody2D
var gate_collision: CollisionShape2D

func setup(plate_position: Vector2, gate_position: Vector2, required_weight := 9) -> void:
	threshold = required_weight
	position = Vector2.ZERO
	plate = Area2D.new()
	plate.position = plate_position
	plate.add_to_group("pressure_plates")
	var plate_shape := CollisionShape2D.new()
	var plate_rect := RectangleShape2D.new()
	plate_rect.size = Vector2(120, 24)
	plate_shape.shape = plate_rect
	plate.add_child(plate_shape)
	add_child(plate)
	gate = StaticBody2D.new()
	gate.position = gate_position
	gate.add_to_group("weight_gates")
	gate_collision = CollisionShape2D.new()
	var gate_rect := RectangleShape2D.new()
	gate_rect.size = Vector2(46, 230)
	gate_collision.shape = gate_rect
	gate.add_child(gate_collision)
	add_child(gate)
	queue_redraw()

func _physics_process(_delta: float) -> void:
	if opened: return
	for body in plate.get_overlapping_bodies():
		if body is ReleasePlayer and int(body.weight) >= threshold:
			opened = true
			gate_collision.set_deferred("disabled", true)
			opened_gate.emit(gate.global_position)
			queue_redraw()
			return

func _draw() -> void:
	if plate == null: return
	draw_rect(Rect2(plate.position - Vector2(60, 9), Vector2(120, 18)), Color("d4ad4f") if opened else Color("7d6940"))
	if not opened:
		draw_rect(Rect2(gate.position - Vector2(23, 115), Vector2(46, 230)), Color("28383b"))
		for y in range(-95, 100, 32): draw_line(gate.position + Vector2(-18, y), gate.position + Vector2(18, y), Color("8fa2a1"), 3)
	else:
		draw_line(gate.position + Vector2(-23, -115), gate.position + Vector2(-23, 115), Color("d4ad4f"), 4)
