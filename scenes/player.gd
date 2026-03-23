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
@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer
@onready var sync_timer: Timer = $SyncTimer


func _ready() -> void:
	sync_timer.timeout.connect(_on_sync_timeout)
	if bullet_scene:
		bullet_spawner.add_spawnable_scene(bullet_scene.resource_path)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	if is_on_floor() and input_synchronizer.jump:
		velocity.y = -jump_speed
		input_synchronizer.jump = false
	
	var move_input: float = input_synchronizer.move_input
	velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
	move_and_slide()
	
	if is_multiplayer_authority():
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
	input_synchronizer.set_multiplayer_authority(data.id, false)
	if is_multiplayer_authority():
		sync_timer.start()

# authority / any_peer
# call_remote / call_local
# reliable / unreliable / unreliable_ordered
@rpc("any_peer", "call_local", "reliable")
func test() -> void:
	Debug.log("test %s" % _data.name)

@rpc("authority", "call_remote", "unreliable_ordered")
func send_data(pos: Vector2, vel: Vector2) -> void:
	global_position = lerp(global_position, pos, 0.5)
	velocity = velocity.lerp(vel, 0.5)

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


func _on_sync_timeout() -> void:
	send_data.rpc(global_position, velocity)
	
