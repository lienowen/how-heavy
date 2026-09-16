extends Node2D

signal return_to_menu
const PlayerType = preload("res://scripts/player.gd")
const StoneType = preload("res://scripts/weight_stone.gd")
const START := Vector2(100, 620)
var player: ReleasePlayer
var fragile: StaticBody2D
var broken := false
var finished := false
var respawning := false
var elapsed := 0.0
var exchanges := 0
var deaths := 0
var checkpoint := START
var checkpoint_weight := 6
var checkpoint_stage := 0
var weight_label: Label
var chapter_label: Label
var stats_label: Label
var hint_label: Label
var result_panel: PanelContainer
var result_label: Label
var background: Texture2D
var kit: Texture2D

func _ready() -> void:
	background = load("res://environment-background-v2.png")
	kit = load("res://environment-kit-fixed.png")
	build_level()
	build_hud()
	spawn_player()
	queue_redraw()

func _process(delta: float) -> void:
	if not finished and not respawning and not get_tree().paused:
		elapsed += delta
	stats_label.text = "%.1f 秒 · %d 次交换 · %d 次失足" % [elapsed, exchanges, deaths]
	if not is_instance_valid(player): return
	player.wind_force = 880.0 if player.position.x > 1260 and player.position.x < 1780 else 0.0
	update_interaction()
	update_checkpoint()
	chapter_label.text = "01 / 越过" if player.position.x < 1200 else ("02 / 逆风" if player.position.x < 2250 else "03 / 坠落")
	if broken and player.position.x > 3370 and player.position.y > 760 and not finished:
		complete_slice()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().paused = false
		get_tree().reload_current_scene()
	elif event.is_action_pressed("pause_game"):
		if finished:
			return_to_menu.emit()
			queue_free()
		else:
			get_tree().paused = not get_tree().paused
			hint_label.text = "已暂停 · Esc 继续" if get_tree().paused else base_hint()

func build_level() -> void:
	make_platform(Rect2(0, 670, 370, 150))
	make_platform(Rect2(700, 670, 520, 150))
	make_stone(Vector2(245, 625), 2)
	make_stone(Vector2(1050, 625), 10)
	make_platform(Rect2(1220, 670, 630, 150))
	make_platform(Rect2(1850, 670, 470, 150))
	make_stone(Vector2(2070, 625), 2)
	make_platform(Rect2(2320, 670, 330, 150))
	make_platform(Rect2(2630, 540, 250, 92))
	make_platform(Rect2(2880, 430, 250, 92))
	make_stone(Vector2(3000, 385), 10)
	fragile = make_platform(Rect2(3130, 670, 185, 32), true)
	make_platform(Rect2(3130, 820, 420, 120))

func make_platform(rect: Rect2, is_fragile := false) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = rect.position + rect.size * 0.5
	body.set_meta("rect", Rect2(-rect.size * 0.5, rect.size))
	body.set_meta("fragile", is_fragile)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
	return body

func make_stone(at: Vector2, value: int) -> void:
	var item: ReleaseStone = StoneType.new()
	item.setup(at, value)
	add_child(item)

func spawn_player() -> void:
	player = PlayerType.new()
	player.position = START
	add_child(player)
	player.weight_changed.connect(update_weight)
	player.exchanged.connect(func(): exchanges += 1)
	player.fell_out.connect(on_fell)
	player.heavy_impact.connect(on_impact)
	var camera := Camera2D.new()
	camera.position = Vector2(0, -250)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 6
	camera.limit_left = 0
	camera.limit_right = 3550
	camera.limit_top = 0
	camera.limit_bottom = 940
	player.add_child(camera)
	update_weight(player.weight)

func build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var top := ColorRect.new()
	top.color = Color(0.015, 0.018, 0.022, 0.84)
	top.size = Vector2(1280, 68)
	layer.add_child(top)
	weight_label = make_hud_label(layer, Vector2(24, 19), 20)
	chapter_label = make_hud_label(layer, Vector2(575, 19), 21)
	stats_label = make_hud_label(layer, Vector2(990, 23), 14)
	hint_label = make_hud_label(layer, Vector2(410, 680), 15)
	hint_label.text = base_hint()
	result_panel = PanelContainer.new()
	result_panel.position = Vector2(410, 220)
	result_panel.custom_minimum_size = Vector2(460, 245)
	result_panel.visible = false
	result_label = Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_label.add_theme_font_size_override("font_size", 22)
	result_panel.add_child(result_label)
	layer.add_child(result_panel)

func make_hud_label(parent: Node, at: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = at
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label

func base_hint() -> String:
	return "A / D 移动 · 空格跳跃 · E 交换重量 · Esc 暂停"

func update_interaction() -> void:
	var nearest: ReleaseStone
	var best := 120.0
	for node in get_tree().get_nodes_in_group("release_stones"):
		var item := node as ReleaseStone
		var distance := player.position.distance_to(item.position)
		if distance < best:
			best = distance
			nearest = item
	if player.nearby != nearest:
		if player.nearby != null: player.nearby.active = false
		player.nearby = nearest
		if nearest != null:
			nearest.active = true
			hint_label.text = "E · 与重量 %d 交换" % nearest.weight
		else: hint_label.text = base_hint()

func update_checkpoint() -> void:
	var marks := [780.0, 1880.0, 2660.0]
	if checkpoint_stage < marks.size() and player.position.x >= marks[checkpoint_stage]:
		checkpoint = Vector2(marks[checkpoint_stage], 620 if checkpoint_stage < 2 else 490)
		checkpoint_weight = player.weight
		checkpoint_stage += 1
		hint_label.text = "检查点已记录"

func update_weight(value: int) -> void:
	var quality := "轻盈" if value <= 3 else ("沉重" if value >= 9 else "适中")
	weight_label.text = "重量 %d · %s" % [value, quality]

func on_fell() -> void:
	if respawning or finished: return
	respawning = true
	deaths += 1
	player.controls_enabled = false
	hint_label.text = "失足 · 返回最近检查点"
	await get_tree().create_timer(0.55).timeout
	player.restore(checkpoint, checkpoint_weight)
	respawning = false
	hint_label.text = base_hint()

func on_impact(at: Vector2, _speed: float) -> void:
	if broken or at.x < 3090: return
	broken = true
	fragile.get_node("CollisionShape2D").set_deferred("disabled", true)
	fragile.visible = false
	queue_redraw()

func complete_slice() -> void:
	finished = true
	player.controls_enabled = false
	Game.complete_level(1, elapsed, exchanges, deaths)
	result_label.text = "这一次，过去了。\n\n%.1f 秒 · %d 次交换 · %d 次失足\n\nR 再来一次 · Esc 返回标题" % [elapsed, exchanges, deaths]
	result_panel.visible = true

func _draw() -> void:
	draw_texture_rect(background, Rect2(0, 0, 3550, 940), false)
	draw_rect(Rect2(0, 0, 3550, 940), Color(0.01, 0.02, 0.035, 0.08))
	for child in get_children():
		if child is StaticBody2D and child.has_meta("rect") and child.visible:
			var rect: Rect2 = child.get_meta("rect")
			var target := Rect2(child.position.x + rect.position.x, child.position.y + rect.position.y - 14, rect.size.x, minf(maxf(rect.size.y, 92), 150))
			var source := Rect2(15, 520, 510, 245) if bool(child.get_meta("fragile")) else Rect2(10, 185, 1070, 240)
			draw_texture_rect_region(kit, target, source)
	draw_rect(Rect2(370, 670, 330, 270), Color(0.005, 0.008, 0.012, 0.95))
	draw_rect(Rect2(1260, 420, 500, 250), Color(0.18, 0.7, 0.84, 0.09))
	for y in range(465, 645, 34):
		draw_line(Vector2(1300, y), Vector2(1720, y - 14), Color(0.52, 0.86, 0.92, 0.8), 3)
	draw_string(ThemeDB.fallback_font, Vector2(1410, 395), "逆风而行", HORIZONTAL_ALIGNMENT_CENTER, 200, 21, Color("c7edf0"))
	draw_string(ThemeDB.fallback_font, Vector2(3040, 625), "唯有沉重，才能坠落", HORIZONTAL_ALIGNMENT_CENTER, 320, 18, Color("edcf78"))
	if broken: draw_rect(Rect2(3130, 670, 185, 270), Color(0.005, 0.008, 0.012, 0.97))
