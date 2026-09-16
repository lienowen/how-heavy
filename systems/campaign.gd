extends Node

const CHAPTERS := [
	{"id": 1, "title": "MEASURE", "subtitle": "Learn what weight permits.", "levels": [1,2,3,4,5,6]},
	{"id": 2, "title": "BALANCE", "subtitle": "Every gain must rest somewhere.", "levels": [7,8,9,10,11,12]},
	{"id": 3, "title": "MOMENTUM", "subtitle": "What moves you may also carry you away.", "levels": [13,14,15,16,17,18]},
	{"id": 4, "title": "COST", "subtitle": "Choose what reaches the other side.", "levels": [19,20,21,22,23,24]}
]

const LEVELS := [
	{"id":1,"name":"First Measure","pattern":"gap","lesson":"Lightness creates distance."},
	{"id":2,"name":"A Stone Left Behind","pattern":"gap_trade","lesson":"A trade always leaves weight somewhere."},
	{"id":3,"name":"Crosswind","pattern":"wind","lesson":"Lightness also surrenders control."},
	{"id":4,"name":"Hold Fast","pattern":"wind_trade","lesson":"Weight can become an anchor."},
	{"id":5,"name":"The Cracked Seal","pattern":"break","lesson":"A heavy fall changes the room."},
	{"id":6,"name":"Measured Passage","pattern":"chapter_exam","lesson":"Combine distance, resistance, and impact."},
	{"id":7,"name":"Two Pans","pattern":"plates","lesson":"The room remembers where weight rests."},
	{"id":8,"name":"Counterpart","pattern":"counterweight","lesson":"Raise one path by lowering another."},
	{"id":9,"name":"Borrowed Ground","pattern":"plates_gap","lesson":"Plan where your old weight will remain."},
	{"id":10,"name":"The Quiet Gate","pattern":"gate","lesson":"The answer can stand apart from you."},
	{"id":11,"name":"Three Bodies","pattern":"multi_trade","lesson":"Order matters when every vessel differs."},
	{"id":12,"name":"In Balance","pattern":"balance_exam","lesson":"Move weight through the whole room."},
	{"id":13,"name":"Carried","pattern":"moving","lesson":"Momentum persists after the trade."},
	{"id":14,"name":"The Long Arc","pattern":"moving_gap","lesson":"Commit before the platform departs."},
	{"id":15,"name":"Against Motion","pattern":"moving_wind","lesson":"Resistance changes a moving frame."},
	{"id":16,"name":"Elastic Memory","pattern":"spring","lesson":"Structures return what you give them."},
	{"id":17,"name":"Falling Together","pattern":"chain","lesson":"Trade while the room is in motion."},
	{"id":18,"name":"Momentum of One","pattern":"momentum_exam","lesson":"Carry a sequence, not a single answer."},
	{"id":19,"name":"No Empty Hands","pattern":"cost_gate","lesson":"The final path requires a burden."},
	{"id":20,"name":"What Remains","pattern":"sacrifice","lesson":"Some weights cannot follow you."},
	{"id":21,"name":"The Other Pan","pattern":"return","lesson":"Look back at what your passage changed."},
	{"id":22,"name":"Unmeasured","pattern":"choice","lesson":"There is more than one honest answer."},
	{"id":23,"name":"The Last Exchange","pattern":"finale","lesson":"Decide what the hall will remember."},
	{"id":24,"name":"The Weight We Carry","pattern":"ending","lesson":"Leave by the path your choices made."}
]

func level(id: int) -> Dictionary:
	if id < 1 or id > LEVELS.size(): return LEVELS[0]
	return LEVELS[id - 1]

func chapter_for_level(id: int) -> int:
	return clampi(((id - 1) / 6) + 1, 1, 4)
