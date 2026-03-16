class_name Player
extends CharacterBody2D

@export var speed: int = 200
@export var acceleration: float = 400
@export var jump_speed: int = 500
@export var bullet_scene: PackedScene

var _data: Statics.PlayerData

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var bullet_spawner: MultiplayerSpawner = $BulletSpawner
@onready var bullet_spawn_marker: Marker2D = $BulletSpawnMarker


func _ready() -> void:
	if bullet_scene:
		bullet_spawner.add_spawnable_scene(bullet_scene.resource_path)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y += get_gravity().y * delta
		
		if is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y = -jump_speed
		
		var move_input: float = Input.get_axis("move_left", "move_right")
		velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
		move_and_slide()
		
		if Input.is_action_just_pressed("fire"):
			var direction: Vector2 = bullet_spawn_marker.global_position.direction_to(get_global_mouse_position())
			fire.rpc_id(1, direction)
		
		#send_position.rpc(global_position)
	
	
	if Input.is_action_just_pressed("test") and is_multiplayer_authority():
		#test.rpc()
		visible = not visible

func change_color() -> void:
	sprite_2d.modulate = Color.RED


func setup(data: Statics.PlayerData) -> void:
	_data = data
	name = str(data.id)
	label.text = data.name
	set_multiplayer_authority(data.id, false)
	multiplayer_synchronizer.set_multiplayer_authority(data.id, false)

# authority / any_peer
# call_remote / call_local
# reliable / unreliable / unreliable_ordered
@rpc("any_peer", "call_local", "reliable")
func test() -> void:
	Debug.log("test %s" % _data.name)

@rpc("authority", "call_remote", "unreliable_ordered")
func send_position(pos: Vector2) -> void:
	global_position = pos


# this only shoul be called on the server
@rpc("authority", "call_local")
func fire(direction: Vector2) -> void:
	if not bullet_scene:
		return
	var bullet_inst = bullet_scene.instantiate()
	bullet_inst.global_position = bullet_spawn_marker.global_position

	bullet_inst.global_rotation = direction.angle()
	bullet_spawner.add_child(bullet_inst, true)


@rpc("any_peer", "call_local")
func test3() -> void:
	Debug.log("test3")
	test4.rpc()
	
	
@rpc("any_peer", "call_local")
func test4() -> void:
	Debug.log("test4")
	test5.rpc()
	


@rpc("any_peer", "call_local")
func test5() -> void:
	Debug.log("test5")
