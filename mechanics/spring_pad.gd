class_name WeightSpringPad
extends Area2D

var power := 720.0
var cooldown := 0.0

func setup(at: Vector2, launch_power := 720.0) -> void:
	position = at
	power = launch_power
	add_to_group("spring_pads")
	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(110, 34)
	collision.shape = rect
	add_child(collision)
	body_entered.connect(on_body_entered)
	queue_redraw()

func _process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)

func on_body_entered(body: Node) -> void:
	if cooldown > 0.0 or not body is ReleasePlayer: return
	cooldown = 0.35
	var weight_ratio := float(body.weight - 2) / 8.0
	body.velocity.y = -lerpf(power, power * 0.64, weight_ratio)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-55, -10, 110, 20), Color("4f7478"))
	for x in range(-38, 39, 19): draw_line(Vector2(x, 7), Vector2(x + 10, -7), Color("d7b85a"), 3)
