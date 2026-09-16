extends Node

func _ready() -> void:
	var feedback := ProductionFeedback.new()
	add_child(feedback)
	feedback.play_exchange(Vector2(200, 200))
	feedback.play_impact(Vector2(300, 300))
	feedback.play_checkpoint(Vector2(400, 300))
	feedback.play_failure(Vector2(500, 350))
	feedback.play_complete(Vector2(640, 350))
	var failures: Array[String] = []
	for event_name in ["exchange", "impact", "checkpoint", "failure", "complete"]:
		if int(feedback.event_counts[event_name]) != 1: failures.append("%s sequence missing" % event_name)
	if feedback.sequence != ProductionFeedback.Sequence.COMPLETE: failures.append("sequence state")
	if failures.is_empty(): print("QA_PASS feedback: exchange, impact, checkpoint, failure and completion sequences")
	else:
		for failure in failures: push_error(failure)
	get_tree().quit(0 if failures.is_empty() else 1)

