extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func  _ready() -> void:
	if is_multiplayer_authority():
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player:
		Game.set_player_coins(player.get_id(), Game.get_player_coins(player.get_id()) + 1)
		pickup_animation.rpc()
		await animation_player.animation_finished
		destroy.rpc()

@rpc("call_local", "reliable")
func destroy() -> void:
	queue_free()
	
@rpc("call_local", "reliable")
func pickup_animation() -> void:
	animation_player.play("pickup")
