extends "res://scripts/world_commercial.gd"
const ACHIEVEMENT_NAMES := {"FIRST_TRADE":"Nothing Stays the Same","LIGHT_STEP":"Light as a Question","HOLD_FAST":"Hold Fast","BREAK_THE_MEASURE":"Break the Measure","CHAPTER_MEASURED":"Measured","TRUE_BALANCE":"In Balance","CARRIED_FORWARD":"Momentum","NO_FALLS":"Sure Footing","NO_TRADE":"What You Already Carry","THE_LAST_EXCHANGE":"The Last Exchange","RELEASED":"An Open Door","CARRIED":"By Choice"}
var achievement_layer: CanvasLayer
var achievement_queue: Array[String] = []
var showing_achievement := false

func _ready() -> void:
	super()
	achievement_layer = CanvasLayer.new()
	achievement_layer.layer = 60
	add_child(achievement_layer)
	Achievements.achievement_unlocked.connect(queue_achievement)

func _exit_tree() -> void:
	if Achievements.achievement_unlocked.is_connected(queue_achievement): Achievements.achievement_unlocked.disconnect(queue_achievement)

func queue_achievement(api_name: String) -> void:
	achievement_queue.append(api_name)
	if not showing_achievement: show_next_achievement()

func show_next_achievement() -> void:
	if achievement_queue.is_empty():
		showing_achievement = false
		return
	showing_achievement = true
	var api_name: String = achievement_queue.pop_front()
	var panel := PanelContainer.new()
	panel.position = Vector2(870, 38)
	panel.size = Vector2(370, 86)
	panel.modulate.a = 0.0
	achievement_layer.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	panel.add_child(box)
	var eyebrow := Label.new()
	eyebrow.text = "ACHIEVEMENT UNLOCKED"
	eyebrow.add_theme_font_size_override("font_size", 12)
	eyebrow.add_theme_color_override("font_color", Color("d7b85a"))
	box.add_child(eyebrow)
	var title := Label.new()
	title.text = str(ACHIEVEMENT_NAMES.get(api_name, api_name))
	title.add_theme_font_size_override("font_size", 20)
	box.add_child(title)
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)
	tween.tween_interval(2.6)
	tween.tween_property(panel, "modulate:a", 0.0, 0.25)
	tween.tween_callback(panel.queue_free)
	tween.tween_callback(show_next_achievement)

