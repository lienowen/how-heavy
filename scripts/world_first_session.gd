extends "res://scripts/world_crazygames.gd"

var tutorial_layer: CanvasLayer
var tutorial_label: Label
var tutorial_stage := 0
var next_button: Button

const ROOM_ONE_PROMPTS := [
	"MOVE RIGHT",
	"TRADE TO LIGHT  •  E / X",
	"LIGHT JUMPS FARTHER  •  CLEAR THE GAP",
	"HEADWIND AHEAD  •  TRADE TO HEAVY",
	"HEAVY RESISTS THE WIND  •  KEEP GOING",
	"YOU GOT IT  •  REACH THE FINISH",
]

func _ready() -> void:
	super()
	if level_id == 1 and not Game.progress.completed.has("1"):
		build_first_session_tutorial()

func _process(delta: float) -> void:
	super(delta)
	if level_id != 1 or not is_instance_valid(tutorial_label) or finished: return
	advance_room_one_tutorial()

func advance_room_one_tutorial() -> void:
	match tutorial_stage:
		0:
			if player.position.x > START.x + 70.0: set_tutorial_stage(1)
		1:
			if exchanges > 0 and player.weight == 2: set_tutorial_stage(2)
		2:
			if player.position.x >= 760.0: set_tutorial_stage(3)
		3:
			if player.weight == 10: set_tutorial_stage(4)
		4:
			if player.position.x >= 1530.0: set_tutorial_stage(5)
		5:
			if player.position.x >= 2050.0:
				set_tutorial_stage(6)
				var tween := create_tween()
				tween.tween_interval(1.5)
				tween.tween_property(tutorial_label, "modulate:a", 0.0, 0.3)

func set_tutorial_stage(value: int) -> void:
	if value == tutorial_stage: return
	tutorial_stage = value
	if tutorial_stage < ROOM_ONE_PROMPTS.size():
		tutorial_label.text = ROOM_ONE_PROMPTS[tutorial_stage]
		tutorial_label.modulate.a = 1.0
		var tween := create_tween()
		tutorial_label.scale = Vector2(0.96, 0.96)
		tween.tween_property(tutorial_label, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func build_first_session_tutorial() -> void:
	tutorial_layer = CanvasLayer.new()
	tutorial_layer.layer = 18
	add_child(tutorial_layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(390, 118)
	panel.size = Vector2(500, 52)
	tutorial_layer.add_child(panel)
	tutorial_label = Label.new()
	tutorial_label.text = ROOM_ONE_PROMPTS[0]
	tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tutorial_label.pivot_offset = Vector2(250, 26)
	tutorial_label.add_theme_font_size_override("font_size", 18)
	panel.add_child(tutorial_label)

func complete_slice() -> void:
	super()
	if level_id >= 24: return
	next_button = Button.new()
	next_button.text = "CONTINUE TO ROOM %02d" % (level_id + 1)
	next_button.position = Vector2(465, 490)
	next_button.size = Vector2(350, 58)
	next_button.add_theme_font_size_override("font_size", 18)
	next_button.pressed.connect(continue_to_next_room)
	result_panel.get_parent().add_child(next_button)
	next_button.grab_focus()

func continue_to_next_room() -> void:
	CrazyGamesBridge.gameplay_start()
	next_level_requested.emit(level_id + 1)
	queue_free()
