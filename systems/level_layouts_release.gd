extends "res://systems/level_layouts.gd"

func room(id: int) -> Dictionary:
	var result: Dictionary = super(id).duplicate(true)
	if id == 1:
		# Clear first-room teaching beat: light for the gap, heavy for the wind.
		result.platforms = [
			[0, 670, 500, 150],
			[840, 670, 760, 150],
			[1600, 670, 1950, 150],
		]
		result.stones = [
			[300, 625, 2],
			[1040, 625, 10],
		]
		result.wind = [[1760, 2580, 700]]
		result.gates = []
		result.movers = []
		result.springs = []
		result.fragile = []
	if id == 13:
		result.platforms.append([2520, 650, 300, 70])
	if id == 14:
		result.platforms.append([690, 650, 210, 70])
		result.platforms.append([2520, 650, 290, 70])
	return result

func signature(id: int) -> String:
	return JSON.stringify(room(id))
