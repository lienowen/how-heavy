extends "res://scripts/world_web_compatible.gd"

func on_trade_sound() -> void:
	Achievements.unlock("FIRST_TRADE")
	super()

func on_impact(at: Vector2, speed: float) -> void:
	var was_broken := broken
	super(at, speed)
	if not was_broken and broken: Achievements.unlock("BREAK_THE_MEASURE")

func choose_ending(choice: String) -> void:
	Achievements.unlock("RELEASED" if choice == "release" else "CARRIED")
	super(choice)

