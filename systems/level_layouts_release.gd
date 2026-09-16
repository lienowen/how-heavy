extends "res://systems/level_layouts.gd"

func room(id: int) -> Dictionary:
	var result: Dictionary = super(id).duplicate(true)
	if id == 1:
		# Room 1 is now a focused onboarding slice: become light to clear one gap,
		# then become heavy to push through one obvious headwind. No gate puzzle,
		# no forced drop, no extra state changes.
		result.platforms = [
			[0, 670, 520, 150],
			[730, 670, 870, 150],
			[1600, 670, 1950, 150],
		]
		result.stones = [
			[285, 625, 2],
			[930, 625, 10],
		]
		result.wind = [[1080, 1510, 620]]
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
