extends "res://scripts/world_performance.gd"
const ChapterEnvironmentType = preload("res://scripts/chapter_environment.gd")

var chapter_environment: ChapterEnvironment

func _ready() -> void:
	# The base world resolves level_id from Game.current_level. Build chapter art only
	# after that initialization so rooms 7, 13 and 19 receive chapters 2, 3 and 4.
	super()
	chapter_environment = ChapterEnvironmentType.new()
	chapter_environment.setup(Campaign.chapter_for_level(level_id))
	add_child(chapter_environment)
	move_child(chapter_environment, 0)
