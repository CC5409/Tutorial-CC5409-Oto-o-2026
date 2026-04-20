extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

func  _ready() -> void:
	if is_multiplayer_authority():
		body_entered.connect(_on_body_entered)
	var tween: Tween = create_tween()
	tween.tween_property(sprite_2d, "position:y", 0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(sprite_2d, "position:y", -20, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.set_loops()


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
