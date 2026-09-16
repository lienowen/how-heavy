extends "res://systems/game_service.gd"

func complete_level(level_id: int, time: float, exchanges: int, deaths: int) -> void:
	super(level_id, time, exchanges, deaths)
	var room_achievements := {1:"LIGHT_STEP",4:"HOLD_FAST",6:"CHAPTER_MEASURED",12:"TRUE_BALANCE",18:"CARRIED_FORWARD",24:"THE_LAST_EXCHANGE"}
	if room_achievements.has(level_id): Achievements.unlock(room_achievements[level_id])
	if deaths == 0: Achievements.unlock("NO_FALLS")
	if exchanges == 0: Achievements.unlock("NO_TRADE")

