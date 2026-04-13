class_name InputSynchronizer
extends MultiplayerSynchronizer

@export var move_input: Vector2
var jump: bool


func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	move_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Input.is_action_just_pressed("jump"):
		set_jump.rpc(true)

@rpc("reliable", "call_local")
func set_jump(value: bool) -> void:
	jump = value
