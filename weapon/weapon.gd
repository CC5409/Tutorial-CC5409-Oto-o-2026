class_name Weapon
extends Node2D

@export var bullet_scene: PackedScene
@onready var bullet_spawner: MultiplayerSpawner = $BulletSpawner
@onready var marker_2d: Marker2D = $Marker2D


func _ready() -> void:
	if bullet_scene:
		bullet_spawner.add_spawnable_scene(bullet_scene.resource_path)


func fire() -> void:
	fire_server.rpc_id(1)


@rpc("any_peer", "call_local", "reliable")
func fire_server() -> void:
	if not bullet_scene:
		return
	var bullet_inst: Bullet = bullet_scene.instantiate()
	bullet_inst.global_position = marker_2d.global_position
	bullet_inst.global_rotation = marker_2d.global_rotation
	bullet_spawner.add_child(bullet_inst, true)
	
