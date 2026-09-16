class_name ChapterEnvironment
extends Node2D

var chapter: int = 1
var motion_time: float = 0.0
var redraw_clock: float = 0.0

const SKY_TOP := Color("70d9ff")
const SKY_BOTTOM := Color("e8f9ff")
const CLOUD := Color(1, 1, 1, 0.92)
const CLOUD_SOFT := Color(1, 1, 1, 0.55)
const CITY_FAR := Color("bce8f5")
const CITY_NEAR := Color("8fd2e6")
const HILL := Color("8ddfbb")
const HILL_DARK := Color("66caa0")
const SUN := Color("fff0a6")

const ACCENTS := [
	Color("45c6ff"),
	Color("4bd7c1"),
	Color("8b9dff"),
	Color("ff9a62")
]

func setup(value: int) -> void:
	chapter = clampi(value, 1, 4)
	z_index = -20
	queue_redraw()

func _process(delta: float) -> void:
	motion_time += delta
	redraw_clock += delta
	if redraw_clock >= 0.08:
		redraw_clock = 0.0
		queue_redraw()

func _draw() -> void:
	draw_sky()
	draw_sun()
	draw_far_city()
	draw_hills()
	draw_clouds()
	draw_trackside_accents()

func draw_sky() -> void:
	# Layered bands create a cleaner pseudo-gradient without shaders.
	draw_rect(Rect2(0, 0, 3550, 720), SKY_BOTTOM)
	draw_rect(Rect2(0, 0, 3550, 220), SKY_TOP)
	draw_rect(Rect2(0, 180, 3550, 170), Color("aeeaff"))
	draw_rect(Rect2(0, 315, 3550, 150), Color("d9f6ff"))

func draw_sun() -> void:
	var x := 1040.0 + sin(motion_time * 0.08) * 8.0
	var center := Vector2(x, 125)
	draw_circle(center, 64, Color(SUN, 0.24))
	draw_circle(center, 46, SUN)

func draw_far_city() -> void:
	# Repeating silhouettes give the runner depth without making the playfield noisy.
	for i in range(30):
		var x := float(i * 128) - fposmod(motion_time * 7.0, 128.0)
		var h := 74.0 + float((i * 37) % 95)
		draw_rect(Rect2(x, 348 - h, 92, h), CITY_FAR)
		if i % 3 == 0:
			draw_rect(Rect2(x + 18, 348 - h - 30, 52, 30), Color(CITY_FAR, 0.9))

	for i in range(22):
		var x2 := float(i * 178) - fposmod(motion_time * 12.0, 178.0)
		var h2 := 82.0 + float((i * 53) % 112)
		draw_rect(Rect2(x2, 405 - h2, 118, h2), CITY_NEAR)

func draw_hills() -> void:
	var points_back := PackedVector2Array()
	points_back.append(Vector2(0, 430))
	for i in range(19):
		var x := float(i * 210)
		var y := 420.0 - sin(i * 0.9) * 45.0
		points_back.append(Vector2(x, y))
	points_back.append(Vector2(3550, 720))
	points_back.append(Vector2(0, 720))
	draw_colored_polygon(points_back, Color(HILL, 0.72))

	var points_front := PackedVector2Array()
	points_front.append(Vector2(0, 500))
	for i in range(18):
		var x2 := float(i * 225)
		var y2 := 490.0 - cos(i * 1.05) * 34.0
		points_front.append(Vector2(x2, y2))
	points_front.append(Vector2(3550, 720))
	points_front.append(Vector2(0, 720))
	draw_colored_polygon(points_front, Color(HILL_DARK, 0.58))

func draw_clouds() -> void:
	for i in range(11):
		var speed := 8.0 + float(i % 3) * 3.0
		var x := fposmod(float(i * 340) + motion_time * speed, 3850.0) - 160.0
		var y := 78.0 + float((i * 61) % 170)
		var scale := 0.78 + float(i % 4) * 0.11
		draw_cloud(Vector2(x, y), scale, CLOUD if i % 2 == 0 else CLOUD_SOFT)

func draw_cloud(at: Vector2, scale: float, color: Color) -> void:
	draw_circle(at + Vector2(-30, 8) * scale, 27 * scale, color)
	draw_circle(at + Vector2(2, -5) * scale, 35 * scale, color)
	draw_circle(at + Vector2(36, 8) * scale, 25 * scale, color)
	draw_rect(Rect2(at + Vector2(-46, 6) * scale, Vector2(92, 28) * scale), color)

func draw_trackside_accents() -> void:
	var accent: Color = ACCENTS[chapter - 1]
	# Sparse flags and rings reinforce a playful runner look while keeping obstacles readable.
	for i in range(14):
		var x := 180.0 + i * 255.0
		var base := Vector2(x, 545)
		draw_line(base, base + Vector2(0, -78), Color(accent, 0.34), 4)
		var flag := PackedVector2Array([
			base + Vector2(0, -78),
			base + Vector2(45, -66),
			base + Vector2(0, -50)
		])
		draw_colored_polygon(flag, Color(accent, 0.48))
	for i in range(8):
		var center := Vector2(360 + i * 430, 470 + ((i % 2) * 24))
		draw_arc(center, 28, 0, TAU, 24, Color(accent, 0.18), 5)
