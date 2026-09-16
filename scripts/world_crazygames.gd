extends "res://scripts/world_commercial_feedback_fixed.gd"

func set_paused(value: bool) -> void:
	if value: CrazyGamesBridge.gameplay_stop()
	else: CrazyGamesBridge.gameplay_start()
	super(value)

func complete_slice() -> void:
	CrazyGamesBridge.gameplay_stop()
	super()

func choose_ending(choice: String) -> void:
	CrazyGamesBridge.happy_time()
	super(choice)

