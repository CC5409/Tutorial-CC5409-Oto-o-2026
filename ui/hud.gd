extends CanvasLayer

@export var player_coins_scene: PackedScene

@onready var player_coins_container: VBoxContainer = %PlayerCoinsContainer

func _ready() -> void:
	for player_data: Statics.PlayerData in Game.players:
		var player_coins_inst: PlayerCoins = player_coins_scene.instantiate()
		player_coins_container.add_child(player_coins_inst)
		player_coins_inst.set_player_data(player_data)
