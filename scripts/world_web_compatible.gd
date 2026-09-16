extends "res://scripts/world_release_content.gd"

var touch_layer: CanvasLayer

func _ready() -> void:
	super()
	if OS.has_feature("web") and DisplayServer.is_touchscreen_available(): build_touch_controls()

func build_touch_controls() -> void:
	touch_layer = CanvasLayer.new()
	touch_layer.layer = 25
	add_child(touch_layer)
	add_touch_button("LEFT", Vector2(28, 610), Vector2(92, 72), "move_left")
	add_touch_button("RIGHT", Vector2(132, 610), Vector2(92, 72), "move_right")
	add_touch_button("JUMP", Vector2(1050, 610), Vector2(92, 72), "jump")
	add_touch_button("TRADE", Vector2(1152, 610), Vector2(100, 72), "exchange")

func add_touch_button(text_value: String, at: Vector2, size: Vector2, action: String) -> void:
	var button := Button.new()
	button.text = text_value
	button.position = at
	button.size = size
	button.modulate = Color(1, 1, 1, 0.72)
	button.focus_mode = Control.FOCUS_NONE
	button.button_down.connect(func(): Input.action_press(action))
	button.button_up.connect(func(): Input.action_release(action))
	touch_layer.add_child(button)
