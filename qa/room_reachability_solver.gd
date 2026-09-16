class_name RoomReachabilitySolver
extends RefCounted

static func solve(layout: Dictionary) -> Dictionary:
	var surfaces := LevelSafetyAnalyzer.build_surfaces(layout)
	var reachable := {}
	var known_weights: Array[int] = [6]
	var start_index := supporting_surface(100.0, surfaces)
	if start_index < 0: return {"solved": false, "reason": "no start", "reachable": 0, "weights": known_weights}
	reachable[start_index] = true
	var changed := true
	var passes := 0
	while changed and passes < 64:
		changed = false
		passes += 1
		for index in reachable.keys():
			for stone in layout.stones:
				if stone_on_surface(stone, surfaces[int(index)]):
					var value := int(stone[2])
					if not known_weights.has(value): known_weights.append(value); changed = true
		for source_index in reachable.keys():
			for target_index in range(surfaces.size()):
				if reachable.has(target_index): continue
				if can_transfer(surfaces[int(source_index)], surfaces[target_index], known_weights, layout.gates):
					reachable[target_index] = true
					changed = true
	var exit_index := supporting_surface(3440.0, surfaces)
	var solved := exit_index >= 0 and reachable.has(exit_index)
	if solved and not layout.fragile.is_empty(): solved = known_weights.has(10)
	return {"solved": solved, "reason": "ok" if solved else "exit unreachable", "reachable": reachable.size(), "surface_count": surfaces.size(), "weights": known_weights, "passes": passes}

static func supporting_surface(x: float, surfaces: Array[Dictionary]) -> int:
	for index in range(surfaces.size()):
		if x >= float(surfaces[index].left) and x <= float(surfaces[index].right): return index
	return -1

static func stone_on_surface(stone: Array, surface: Dictionary) -> bool:
	var x := float(stone[0])
	var y := float(stone[1])
	return x >= float(surface.left) - 45.0 and x <= float(surface.right) + 45.0 and y <= float(surface.top) and y >= float(surface.top) - 180.0

static func can_transfer(source: Dictionary, target: Dictionary, weights: Array[int], gates: Array) -> bool:
	var forward_gap := float(target.left) - float(source.right)
	var reverse_gap := float(source.left) - float(target.right)
	var gap := maxf(forward_gap, reverse_gap)
	if gap < -10.0: return true
	var rise := float(source.top) - float(target.top)
	if rise < -360.0: return false
	for weight in weights:
		if gap <= jump_distance(weight) and rise <= jump_height(weight):
			if gate_allows(source, target, weight, gates): return true
	return false

static func gate_allows(source: Dictionary, target: Dictionary, weight: int, gates: Array) -> bool:
	var left := minf(float(source.right), float(target.left))
	var right := maxf(float(source.right), float(target.left))
	for gate in gates:
		var gate_x := float(gate[2])
		if gate_x >= left and gate_x <= right and weight < int(gate[4]): return false
	return true

static func jump_distance(weight: int) -> float:
	var ratio := float(weight - 2) / 8.0
	var speed := lerpf(315.0, 220.0, ratio)
	var impulse := lerpf(660.0, 420.0, ratio)
	var gravity := lerpf(900.0, 1500.0, ratio)
	return speed * (2.0 * impulse / gravity) + 70.0

static func jump_height(weight: int) -> float:
	var ratio := float(weight - 2) / 8.0
	var impulse := lerpf(660.0, 420.0, ratio)
	var gravity := lerpf(900.0, 1500.0, ratio)
	return impulse * impulse / (2.0 * gravity) + 35.0

