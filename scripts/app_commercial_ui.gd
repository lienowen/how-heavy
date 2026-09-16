extends "res://scripts/app_crazygames.gd"
const CommercialWorld = preload("res://scripts/world_commercial_ui.gd")

func _ready() -> void:
	web_audio_armed = not OS.has_feature("web")
	if Game.progress.completed.is_empty() and int(Game.progress.unlocked_level) <= 1: launch_level(1)
	else: show_title()

func clear_view() -> void:
	super()
	screen.theme = ProductionTheme.build()

func add_backdrop() -> void:
	# Bright, lightweight backdrop designed for portal thumbnails and quick first-read clarity.
	var sky := ColorRect.new()
	sky.color = Color("dff7ff")
	sky.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(sky)

	var top_band := ColorRect.new()
	top_band.color = Color("78d7ff")
	top_band.position = Vector2.ZERO
	top_band.size = Vector2(1280, 245)
	screen.add_child(top_band)

	var horizon := ColorRect.new()
	horizon.color = Color("aeeaff")
	horizon.position = Vector2(0, 210)
	horizon.size = Vector2(1280, 160)
	screen.add_child(horizon)

	var ground := ColorRect.new()
	ground.color = Color("8bd8b4")
	ground.position = Vector2(0, 520)
	ground.size = Vector2(1280, 200)
	screen.add_child(ground)

	# Large soft shapes make the menu feel game-like without depending on raster key art.
	for spec in [
		[Vector2(865, 118), 110.0, Color(1, 0.94, 0.64, 0.92)],
		[Vector2(1010, 330), 155.0, Color(1, 1, 1, 0.76)],
		[Vector2(1145, 405), 105.0, Color(1, 1, 1, 0.60)],
		[Vector2(775, 410), 92.0, Color(1, 1, 1, 0.56)]
	]:
		var circle := Polygon2D.new()
		var points := PackedVector2Array()
		for i in range(40):
			var angle := TAU * float(i) / 40.0
			points.append(Vector2(cos(angle), sin(angle)) * float(spec[1]))
		circle.polygon = points
		circle.position = spec[0]
		circle.color = spec[2]
		screen.add_child(circle)

func launch_level(level_id: int) -> void:
	Game.current_level = clampi(level_id, 1, 24)
	if is_instance_valid(screen): screen.queue_free()
	screen = null
	world = CommercialWorld.new()
	world.return_to_menu.connect(show_chapters)
	world.next_level_requested.connect(launch_level)
	add_child(world)
	CrazyGamesBridge.gameplay_start()

