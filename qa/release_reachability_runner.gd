extends Node
func _ready() -> void:
	var failures: Array[String] = []
	for room_id in range(1, 25):
		if room_id == 23: continue
		var result := RoomReachabilitySolver.solve(LevelLayouts.room(room_id))
		if not bool(result.solved): failures.append("room %02d base route failed" % room_id)
	var room_23 := LevelLayouts.room(23)
	var has_light := false
	var has_heavy := false
	for stone in room_23.stones:
		if float(stone[0]) < 2900.0 and int(stone[2]) == 2: has_light = true
		if float(stone[0]) < 2900.0 and int(stone[2]) >= 10: has_heavy = true
	var gate_can_open := false
	for gate in room_23.gates:
		if float(gate[2]) > 2900.0 and int(gate[4]) <= 10: gate_can_open = true
	var final_gap := float(room_23.fragile[0][0]) - (float(room_23.platforms[4][0]) + float(room_23.platforms[4][2]))
	if not has_light: failures.append("room 23 lacks light state")
	if not has_heavy or not gate_can_open: failures.append("room 23 gate state")
	if final_gap > RoomReachabilitySolver.jump_distance(2): failures.append("room 23 final jump")
	if failures.is_empty(): print("QA_PASS release reachability: 23 generic routes plus room 23 persistent-gate/light-jump route")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)
