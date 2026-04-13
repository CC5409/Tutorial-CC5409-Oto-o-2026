class_name PlayerCoins
extends HBoxContainer

var _player_data: Statics.PlayerData

@onready var player_name_label: Label = $PlayerNameLabel
@onready var coins_label: Label = $CoinsLabel


func set_player_data(value: Statics.PlayerData)-> void:
	_player_data = value
	player_name_label.text = _player_data.name
	coins_label.text = str(_player_data.coins)
	_player_data.coins_changed.connect(_on_coins_changed)


func _on_coins_changed(value: int) -> void:
	coins_label.text = str(value)
	
