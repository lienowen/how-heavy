class_name LevelSafetyAnalyzer
extends RefCounted

const START_X := 100.0
const EXIT_X := 3440.0
const CHECKPOINTS := [780.0, 1880.0, 2660.0]

static func analyze(room_id: int, layout: Dictionary) -> Array[String]:
	var issues: Array[String] = []
	var surfaces := build_surfaces(layout)
	if not point_has_support(START_X, surfaces): issues.append("start has no supporting surface")
	if not point_has_support(EXIT_X, surfaces): issues.append("exit has no supporting surface")
	for checkpoint_x in CHECKPOINTS:
		if not has_safe_landing_after(checkpoint_x, surfaces, 520.0): issues.append("checkpoint %.0f has no reachable landing surface" % checkpoint_x)
	var weights := available_weights(layout)
	if weights.is_empty(): issues.append("no weight vessels")
	for value in weights:
		if value < 2 or value > 10: issues.append("invalid vessel weight %d" % value)
	for gate in layout.gates:
		var threshold := int(gate[4])
		if not has_weight_at_least(weights, threshold): issues.append("gate threshold %d has no available weight" % threshold)
		if not interval_has_support(float(gate[0]) - 60.0, float(gate[0]) + 60.0, surfaces): issues.append("gate plate at %.0f has no supporting overlap" % float(gate[0]))
	if not layout.fragile.is_empty():
		if not has_weight_at_least(weights, 10): issues.append("fragile floor has no weight 10 resource")
		var fragile = layout.fragile[0]
		if float(fragile[0]) >= EXIT_X: issues.append("fragile floor begins beyond exit trigger")
	issues.append_array(check_surface_chain(surfaces))
	return issues

static func build_surfaces(layout: Dictionary) -> Array[Dictionary]:
	var surfaces: Array[Dictionary] = []
	for item in layout.platforms: surfaces.append({"left": float(item[0]), "right": float(item[0]) + float(item[2]), "top": float(item[1]), "dynamic": false})
	for item in layout.fragile: surfaces.append({"left": float(item[0]), "right": float(item[0]) + float(item[2]), "top": float(item[1]), "dynamic": false})
	for item in layout.movers:
		var start_x := float(item[0]) - 95.0
		var end_x := float(item[0]) + float(item[2]) + 95.0
		surfaces.append({"left": minf(start_x, end_x), "right": maxf(start_x, end_x), "top": minf(float(item[1]), float(item[1]) + float(item[3])), "dynamic": true})
	surfaces.sort_custom(func(a: Dictionary, b: Dictionary): return float(a.left) < float(b.left))
	return surfaces

static func point_has_support(x: float, surfaces: Array[Dictionary]) -> bool:
	for surface in surfaces:
		if x >= float(surface.left) and x <= float(surface.right): return true
	return false

static func interval_has_support(left: float, right: float, surfaces: Array[Dictionary]) -> bool:
	for surface in surfaces:
		if maxf(left, float(surface.left)) <= minf(right, float(surface.right)): return true
	return false

static func has_safe_landing_after(x: float, surfaces: Array[Dictionary], max_distance: float) -> bool:
	for surface in surfaces:
		if bool(surface.dynamic): continue
		var landing_x := maxf(x, float(surface.left))
		if landing_x <= float(surface.right) and landing_x <= x + max_distance: return true
	return false

static func available_weights(layout: Dictionary) -> Array[int]:
	var values: Array[int] = [6]
	for stone in layout.stones:
		var value := int(stone[2])
		if not values.has(value): values.append(value)
	return values

static func has_weight_at_least(weights: Array[int], threshold: int) -> bool:
	for value in weights:
		if value >= threshold: return true
	return false

static func check_surface_chain(surfaces: Array[Dictionary]) -> Array[String]:
	var issues: Array[String] = []
	if surfaces.is_empty(): return ["room has no surfaces"]
	var reachable_right := 0.0
	for surface in surfaces:
		var left := float(surface.left)
		var right := float(surface.right)
		if left > reachable_right + 520.0: issues.append("unbridged horizontal gap %.0f..%.0f" % [reachable_right, left])
		reachable_right = maxf(reachable_right, right)
	if reachable_right < EXIT_X: issues.append("surface chain ends before exit at %.0f" % reachable_right)
	return issues
