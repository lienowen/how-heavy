class_name ReleasePlayer
extends CharacterBody2D

signal weight_changed(value: int)
signal exchanged
signal fell_out
signal heavy_impact(at: Vector2, speed: float)

var weight := 6:
	set(value):
		weight = clampi(value, 2, 10)
		weight_changed.emit(weight)
		queue_redraw()
var controls_enabled := true
var nearby: Area2D
var wind_force := 0.0
var peak_fall := 0.0
var fall_reported := false
var sprite_sheet: Texture2D
var exchange_lock := 0.0
const EXCHANGE_LOCK_SECONDS := 0.18

func _ready() -> void:
	sprite_sheet = load("res://character-weight-sheet-fixed.png")
	var collision := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 17
	capsule.height = 54
	collision.shape = capsule
	collision.position = Vector2(0, -27)
	add_child(collision)
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not controls_enabled:
		velocity = Vector2.ZERO
		return
	exchange_lock = maxf(0.0, exchange_lock - delta)
	var grounded_before := is_on_floor()
	var ratio := float(weight - 2) / 8.0
	var axis := Input.get_axis("move_left", "move_right")
	# Light is an intentional traversal state: it accelerates and rises far
	# enough to make a visible, dependable difference from Balanced.
	velocity.x = move_toward(velocity.x, axis * lerpf(350.0, 220.0, ratio), 2100.0 * delta)
	if not is_on_floor():
		velocity.y += lerpf(900.0, 1500.0, ratio) * delta
		peak_fall = maxf(peak_fall, velocity.y)
	elif Input.is_action_just_pressed("jump"):
		velocity.y = -lerpf(800.0, 420.0, ratio)
	velocity.x -= wind_force * maxf(0.0, (12.0 - weight) / 10.0) * delta
	move_and_slide()
	if not grounded_before and is_on_floor():
		if weight >= 10 and peak_fall > 500.0:
			heavy_impact.emit(global_position, peak_fall)
		peak_fall = 0.0
	if Input.is_action_just_pressed("exchange") and nearby != null and exchange_lock <= 0.0:
		var stored: int = nearby.get("weight")
		if stored != weight:
			nearby.set("weight", weight)
			weight = stored
			exchange_lock = EXCHANGE_LOCK_SECONDS
			exchanged.emit()
	if global_position.y > 940 and not fall_reported:
		fall_reported = true
		fell_out.emit()

func restore(at: Vector2, restored_weight: int) -> void:
	global_position = at
	velocity = Vector2.ZERO
	peak_fall = 0
	fall_reported = false
	exchange_lock = 0.0
	weight = restored_weight
	controls_enabled = true

func _draw() -> void:
	if sprite_sheet == null: return
	var source := Rect2(610, 120, 560, 710)
	if weight <= 3: source = Rect2(30, 35, 540, 790)
	elif weight >= 9: source = Rect2(1190, 175, 570, 650)
	var height := 100.0
	var width := source.size.x / source.size.y * height
	draw_texture_rect_region(sprite_sheet, Rect2(-width * 0.5, -height, width, height), source)
