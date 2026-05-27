@tool
extends BTAction

@export var text: String
var time = 0
var max_time = 1

func _enter() -> void:
	time = 0

func _generate_name() -> String:
	return "DebugLog text: \"%s\"" % text

func _tick(delta: float) -> Status:
	time += delta
	if time > max_time:
		Debug.log(text)
		return SUCCESS
	else:
		return RUNNING
