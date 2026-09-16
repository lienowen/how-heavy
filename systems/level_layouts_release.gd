extends "res://systems/level_layouts.gd"

func room(id: int) -> Dictionary:
	var result: Dictionary = super(id).duplicate(true)
	if id == 1:
		result.platforms[1] = [700, 670, 520, 150]
		result.platforms[2] = [1220, 760, 630, 60]
		result.stones[0] = [286, 625, 2]
		result.stones[2] = [1740, 715, 6]
		result.wind = [[790, 1160, 520]]
		result.gates = [[1110, 650, 1300, 645, 10]]
	if id == 13:
		result.platforms.append([2520, 650, 300, 70])
	if id == 14:
		result.platforms.append([690, 650, 210, 70])
		result.platforms.append([2520, 650, 290, 70])
	return result

func signature(id: int) -> String:
	return JSON.stringify(room(id))
