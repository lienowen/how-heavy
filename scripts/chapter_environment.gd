class_name ChapterEnvironment
extends Node2D

var chapter: int = 1
var motion_time: float = 0.0
var redraw_clock: float = 0.0
var motif_count: int = 0

const PALETTES := [
	{"accent": Color("d7bd72"), "secondary": Color("75999b"), "haze": Color(0.19, 0.28, 0.29, 0.10)},
	{"accent": Color("b8d1c7"), "secondary": Color("c5a45d"), "haze": Color(0.18, 0.32, 0.31, 0.11)},
	{"accent": Color("9da5d1"), "secondary": Color("72c2cc"), "haze": Color(0.22, 0.22, 0.38, 0.12)},
	{"accent": Color("d18c68"), "secondary": Color("d7b85a"), "haze": Color(0.38, 0.16, 0.10, 0.13)}
]

func setup(value: int) -> void:
	chapter = clampi(value, 1, 4)
	motif_count = [12, 10, 14, 12][chapter - 1]
	z_index = -2
	queue_redraw()

func _process(delta: float) -> void:
	motion_time += delta
	redraw_clock += delta
	if redraw_clock >= 0.125:
		redraw_clock = 0.0
		queue_redraw()

func palette() -> Dictionary: return PALETTES[chapter - 1]

func _draw() -> void:
	var colors: Dictionary = palette()
	draw_rect(Rect2(0, 88, 3550, 560), colors.haze)
	if chapter == 1: draw_measure(colors)
	elif chapter == 2: draw_balance(colors)
	elif chapter == 3: draw_momentum(colors)
	else: draw_cost(colors)
	for i: int in range(motif_count):
		var x: float = fposmod(i * 293.0 + motion_time * (5.0 + chapter), 3550.0)
		var y: float = 175.0 + fposmod(i * 83.0, 390.0)
		draw_circle(Vector2(x, y), 1.5 + i % 2, Color(colors.secondary, 0.24))

func draw_measure(colors: Dictionary) -> void:
	for x: int in range(130, 3550, 420):
		draw_line(Vector2(x, 170), Vector2(x, 610), Color(colors.accent, 0.18), 2)
		for y: int in range(190, 600, 54): draw_line(Vector2(x, y), Vector2(x + (20 if y % 108 == 82 else 11), y), Color(colors.accent, 0.38), 2)
	for x: int in range(520, 3550, 900):
		var sway: float = sin(motion_time * 0.5 + x) * 9.0
		draw_line(Vector2(x, 130), Vector2(x + sway, 300), Color(colors.secondary, 0.3), 2)
		draw_arc(Vector2(x + sway, 322), 22, 0, TAU, 24, Color(colors.accent, 0.5), 3)

func draw_balance(colors: Dictionary) -> void:
	for x: int in range(380, 3550, 860):
		var center := Vector2(x, 275)
		var arm := Vector2(145, 0).rotated(sin(motion_time * 0.35 + x) * 0.03)
		draw_line(center + Vector2(0, -100), center + Vector2(0, 160), Color(colors.accent, 0.28), 3)
		draw_line(center - arm, center + arm, Color(colors.accent, 0.5), 4)
		for side: float in [-1.0, 1.0]:
			var edge: Vector2 = center + arm * side
			draw_line(edge, edge + Vector2(0, 88), Color(colors.accent, 0.3), 2)
			draw_arc(edge + Vector2(0, 102), 36, 0.1, PI - 0.1, 20, Color(colors.secondary, 0.44), 3)

func draw_momentum(colors: Dictionary) -> void:
	for x: int in range(240, 3550, 560):
		var center := Vector2(x, 320 + posmod(x, 95))
		var phase: float = motion_time * 0.32 + x * 0.002
		for ring: int in range(2): draw_arc(center, 48 + ring * 27, phase + ring, phase + 4.7 + ring, 28, Color(colors.accent, 0.25 + ring * 0.08), 3)
		for spoke: int in range(4):
			var angle: float = phase + spoke * PI * 0.5
			draw_line(center + Vector2(cos(angle), sin(angle)) * 27, center + Vector2(cos(angle), sin(angle)) * 68, Color(colors.secondary, 0.3), 2)

func draw_cost(colors: Dictionary) -> void:
	for x: int in range(330, 3550, 760):
		var center := Vector2(x, 335 + posmod(x, 80))
		draw_arc(center, 84, -2.8, -0.2, 30, Color(colors.accent, 0.4), 5)
		draw_arc(center, 84, 0.4, 2.2, 22, Color(colors.secondary, 0.32), 3)
		draw_polyline(PackedVector2Array([center + Vector2(-8, -80), center + Vector2(9, -38), center + Vector2(-4, 0), center + Vector2(15, 40), center + Vector2(3, 78)]), Color(colors.accent, 0.52), 3)
	for x: int in range(120, 3550, 300):
		var ember_y: float = 580.0 - fposmod(motion_time * 20.0 + x, 350.0)
		draw_circle(Vector2(x, ember_y), 2.0, Color(colors.accent, 0.5))
