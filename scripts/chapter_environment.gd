class_name ChapterEnvironment
extends Node2D

var chapter: int = 1
var motion_time: float = 0.0
var redraw_clock: float = 0.0

const SKY_TOP := Color("6fd6fb")
const SKY_MID := Color("bfeeff")
const SKY_BOTTOM := Color("eefaff")
const CLOUD := Color(1, 1, 1, 0.92)
const CITY := Color(0.30, 0.60, 0.72, 0.18)
const HILL_BACK := Color("a7e2c2")
const HILL_FRONT := Color("74c99c")
const SUN := Color("fff1a6")

func setup(value: int) -> void:
	chapter = clampi(value, 1, 4)
	z_index = -20
	queue_redraw()

func _process(delta: float) -> void:
	motion_time += delta
	redraw_clock += delta
	if redraw_clock >= 0.10:
		redraw_clock = 0.0
		queue_redraw()

func _draw() -> void:
	draw_sky()
	draw_sun()
	draw_far_city()
	draw_hills()
	draw_clouds()

func draw_sky() -> void:
	draw_rect(Rect2(0, 0, 3550, 720), SKY_BOTTOM)
	draw_rect(Rect2(0, 0, 3550, 210), SKY_TOP)
	draw_rect(Rect2(0, 180, 3550, 200), SKY_MID)

func draw_sun() -> void:
	var center := Vector2(1060.0, 120.0)
	draw_circle(center, 52, Color(SUN, 0.22))
	draw_circle(center, 36, Color(SUN, 0.90))

func draw_far_city() -> void:
	# Keep the skyline low and faint. It should provide depth, not compete with gameplay.
	for i in range(18):
		var x := float(i * 210) - fposmod(motion_time * 5.0, 210.0)
		var h := 45.0 + float((i * 29) % 72)
		draw_rect(Rect2(x, 400.0 - h, 118.0, h), CITY)
		if i % 4 == 0:
			draw_rect(Rect2(x + 24.0, 400.0 - h - 18.0, 56.0, 18.0), Color(CITY, 0.8))

func draw_hills() -> void:
	var back := PackedVector2Array([
		Vector2(0, 470), Vector2(420, 435), Vector2(830, 460), Vector2(1260, 420),
		Vector2(1740, 462), Vector2(2210, 430), Vector2(2700, 470), Vector2(3160, 438),
		Vector2(3550, 460), Vector2(3550, 720), Vector2(0, 720)
	])
	draw_colored_polygon(back, Color(HILL_BACK, 0.88))

	var front := PackedVector2Array([
		Vector2(0, 535), Vector2(390, 505), Vector2(820, 535), Vector2(1300, 500),
		Vector2(1780, 540), Vector2(2260, 505), Vector2(2740, 540), Vector2(3190, 510),
		Vector2(3550, 530), Vector2(3550, 720), Vector2(0, 720)
	])
	draw_colored_polygon(front, Color(HILL_FRONT, 0.72))

func draw_clouds() -> void:
	for i in range(7):
		var speed := 5.0 + float(i % 3) * 2.0
		var x := fposmod(float(i * 520) + motion_time * speed, 3900.0) - 180.0
		var y := 82.0 + float((i * 73) % 145)
		var scale := 0.72 + float(i % 3) * 0.12
		draw_cloud(Vector2(x, y), scale)

func draw_cloud(at: Vector2, scale: float) -> void:
	draw_circle(at + Vector2(-28, 8) * scale, 24 * scale, CLOUD)
	draw_circle(at + Vector2(0, -4) * scale, 31 * scale, CLOUD)
	draw_circle(at + Vector2(33, 8) * scale, 23 * scale, CLOUD)
	draw_rect(Rect2(at + Vector2(-42, 7) * scale, Vector2(84, 23) * scale), CLOUD)
