extends "res://scripts/world_authored.gd"

func update_checkpoint() -> void:
	var marks := [780.0, 1880.0, 2660.0]
	if checkpoint_stage < marks.size() and player.position.x >= marks[checkpoint_stage] and player.is_on_floor():
		checkpoint = player.position
		checkpoint_weight = player.weight
		checkpoint_stage += 1
		hint_label.text = "CHECKPOINT RECORDED"
		if is_instance_valid(audio_director): audio_director.play_named("checkpoint")
