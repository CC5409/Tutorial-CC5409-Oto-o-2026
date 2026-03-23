class_name InputSynchronizer
extends MultiplayerSynchronizer

@export var move_input: float
var jump: bool


func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	move_input = Input.get_axis("move_left", "move_right")
	if Input.is_action_just_pressed("jump"):
		set_jump.rpc(true)

@rpc("reliable", "call_local")
func set_jump(value: bool) -> void:
	jump = value
