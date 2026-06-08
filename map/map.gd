extends Control

@export var map_maker_scene: PackedScene
@onready var origin: Control = $Map/Origin
@onready var map: Panel = $Map

var zoom: float = 1
var zoom_enabled: bool = false

func _ready() -> void:
	map.mouse_entered.connect(func() -> void: zoom_enabled = true)
	map.mouse_exited.connect(func() -> void: zoom_enabled = false)
	
	if not map_maker_scene:
		return
	set_process(false)
	await get_tree().create_timer(1).timeout
	for node: Node in get_tree().get_nodes_in_group("player"):
		var player: Player = node as Player
		var map_marker_inst: MapMarker = map_maker_scene.instantiate()
		map_marker_inst.target = player
		origin.add_child(map_marker_inst)
	for node: Node in get_tree().get_nodes_in_group("enemy"):
		var enemy: Enemy = node as Enemy
		var map_marker_inst: MapMarker = map_maker_scene.instantiate()
		map_marker_inst.target = enemy
		origin.add_child(map_marker_inst)
	set_process(true)


func _input(event: InputEvent) -> void:
	if not zoom_enabled:
		return
	if event.is_action_pressed("zoom_up"):
		zoom += 0.1
	if event.is_action_pressed("zoom_down"):
		zoom -= 0.1

func _process(_delta: float) -> void:
	var current_player_scene: Player = Game.get_current_player().scene
	
	for child: Node in origin.get_children():
		var map_maker: MapMarker = child as MapMarker
		map_maker.position = (map_maker.target.global_position - current_player_scene.global_position) * zoom
