class_name ChapterEnvironment
extends Node2D

var chapter: int = 1
var motion_time: float = 0.0
var redraw_clock: float = 0.0

const SKY_TOP := Color("74d3f5")
const SKY_MID := Color("c7efff")
const SKY_BOTTOM := Color("f2fbff")
const CLOUD := Color(1, 1, 1, 0.93)
const HILL_BACK := Color("b6dfc4")
const HILL_FRONT := Color("78bd8d")
const SUN := Color("fff0a0")
const CASTLE := Color(0.18, 0.33, 0.39, 0.18)

func setup(value: int) -> void:
	chapter = clampi(value, 1, 4)
	z_index = -20
	queue_redraw()

func _process(delta: float) -> void:
	motion_time += delta
	redraw_clock += delta
	if redraw_clock >= 0.12:
		redraw_clock = 0.0
		queue_redraw()

func _draw() -> void:
	draw_sky()
	draw_sun()
	draw_mountains()
	draw_castle()
	draw_hills()
	draw_clouds()

func draw_sky() -> void:
	draw_rect(Rect2(0, 0, 3550, 720), SKY_BOTTOM)
	draw_rect(Rect2(0, 0, 3550, 190), SKY_TOP)
	draw_rect(Rect2(0, 165, 3550, 210), SKY_MID)

func draw_sun() -> void:
	var center := Vector2(1045, 118)
	draw_circle(center, 58, Color(SUN, 0.17))
	draw_circle(center, 34, Color(SUN, 0.88))

func draw_mountains() -> void:
	var back := PackedVector2Array([
		Vector2(0,430), Vector2(260,300), Vector2(520,405), Vector2(840,250), Vector2(1160,410),
		Vector2(1470,285), Vector2(1780,415), Vector2(2120,270), Vector2(2460,410), Vector2(2820,300),
		Vector2(3180,420), Vector2(3550,285), Vector2(3550,720), Vector2(0,720)
	])
	draw_colored_polygon(back, Color("82bbcf", 0.22))

	var mid := PackedVector2Array([
		Vector2(0,470), Vector2(430,365), Vector2(770,450), Vector2(1180,350), Vector2(1570,455),
		Vector2(2000,360), Vector2(2440,465), Vector2(2920,365), Vector2(3300,455), Vector2(3550,390),
		Vector2(3550,720), Vector2(0,720)
	])
	draw_colored_polygon(mid, Color("78aebc", 0.18))

func draw_castle() -> void:
	# One recognizable landmark gives depth without the old repeating rectangle skyline.
	var center_x := 1820.0
	var base_y := 392.0
	draw_rect(Rect2(center_x - 95, base_y - 54, 190, 54), CASTLE)
	draw_rect(Rect2(center_x - 66, base_y - 112, 48, 112), CASTLE)
	draw_rect(Rect2(center_x + 24, base_y - 92, 44, 92), CASTLE)
	draw_rect(Rect2(center_x - 8, base_y - 138, 38, 138), CASTLE)
	for x in [-66.0, -18.0, 24.0]:
		draw_rect(Rect2(center_x + x, base_y - 118, 12, 14), Color(CASTLE, 0.95))

func draw_hills() -> void:
	var back := PackedVector2Array([
		Vector2(0,500), Vector2(420,452), Vector2(840,492), Vector2(1260,445), Vector2(1680,500),
		Vector2(2100,458), Vector2(2550,505), Vector2(3060,462), Vector2(3550,492), Vector2(3550,720), Vector2(0,720)
	])
	draw_colored_polygon(back, Color(HILL_BACK, 0.92))

	var front := PackedVector2Array([
		Vector2(0,555), Vector2(430,520), Vector2(880,552), Vector2(1320,516), Vector2(1780,558),
		Vector2(2240,522), Vector2(2740,560), Vector2(3190,526), Vector2(3550,548), Vector2(3550,720), Vector2(0,720)
	])
	draw_colored_polygon(front, Color(HILL_FRONT, 0.80))

func draw_clouds() -> void:
	for i in range(6):
		var speed := 4.0 + float(i % 3) * 1.5
		var x := fposmod(float(i * 620) + motion_time * speed, 4050.0) - 220.0
		var y := 78.0 + float((i * 79) % 132)
		var scale := 0.78 + float(i % 3) * 0.11
		draw_cloud(Vector2(x, y), scale)

func draw_cloud(at: Vector2, scale: float) -> void:
	draw_circle(at + Vector2(-30, 8) * scale, 25 * scale, CLOUD)
	draw_circle(at + Vector2(0, -5) * scale, 32 * scale, CLOUD)
	draw_circle(at + Vector2(34, 8) * scale, 24 * scale, CLOUD)
	draw_rect(Rect2(at + Vector2(-44, 7) * scale, Vector2(88, 24) * scale), CLOUD)
