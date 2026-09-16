class_name WeightMovingPlatform
extends AnimatableBody2D

var origin := Vector2.ZERO
var travel := Vector2(260, 0)
var period := 3.5
var phase := 0.0
var size := Vector2(190, 28)

func setup(at: Vector2, movement: Vector2, seconds: float, offset := 0.0) -> void:
	position = at
	origin = at
	travel = movement
	period = seconds
	phase = offset
	add_to_group("moving_platforms")
	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	collision.shape = rect
	add_child(collision)
	queue_redraw()

func _physics_process(delta: float) -> void:
	phase += delta * TAU / period
	position = origin + travel * ((sin(phase) + 1.0) * 0.5)

func _draw() -> void:
	draw_rect(Rect2(-size * 0.5, size), Color("33484b"))
	draw_line(Vector2(-size.x * 0.4, 0), Vector2(size.x * 0.4, 0), Color("d4ad4f"), 4)
