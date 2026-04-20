extends Node2D

@onready var players: Node2D = $YSort/Players
@onready var spawn_points: Node2D = $SpawnPoints

@export var player_scene: Dictionary[Statics.Role, PackedScene]

func _ready() -> void:
	for i: int in Game.players.size():
		var player_data: Statics.PlayerData = Game.players[i]
		var scene: PackedScene = player_scene.get(player_data.role)
		if not scene:
			continue
		var player_inst: Player = scene.instantiate()
		players.add_child(player_inst, true)
		var spawn_point: Node2D = spawn_points.get_child(i)
		player_inst.global_position = spawn_point.global_position
		player_inst.setup(player_data)
