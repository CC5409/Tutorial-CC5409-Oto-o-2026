extends StaticBody2D

@export var coins: int = 20

var _players_inside: Array[Player]

@onready var area_2d: Area2D = $Area2D
@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	label.hide()
	if multiplayer.is_server():
		area_2d.body_entered.connect(_on_body_entered)
		area_2d.body_exited.connect(_on_body_exited)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact.rpc_id(1)


func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player:
		_players_inside.push_back(player)
		player_inside.rpc_id(player.get_data().id, true)


func _on_body_exited(body: Node2D) -> void:
	var player: Player = body as Player
	if player:
		_players_inside.erase(player)
		player_inside.rpc_id(player.get_data().id, false)


@rpc("any_peer", "call_local", "reliable")
func open() -> void:
	animation_player.play("open")
	await get_tree().create_timer(0.8).timeout
	queue_free()


@rpc("any_peer", "reliable", "call_local")
func interact() -> void:
	if not multiplayer.is_server():
		return
	var player_id: int = multiplayer.get_remote_sender_id()
	if _players_inside.has(Game.get_player(player_id).scene):
		Game.set_player_coins(player_id, Game.get_player_coins(player_id) + coins)
		open.rpc()


@rpc("any_peer", "reliable", "call_local")
func player_inside(value: bool) -> void:
	label.visible = value
