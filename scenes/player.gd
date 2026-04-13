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
@onready var bullet_spawn_marker: Marker2D = $Pivot/BulletSpawnMarker
@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer
@onready var sync_timer: Timer = $SyncTimer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/movement/playback"]
@onready var pivot: Node2D = $Pivot
@onready var health_component: HealthComponent = $HealthComponent
@onready var camera_2d: Camera2D = $Camera2D


func _ready() -> void:

	health_component.health_changed.connect(_on_health_changed)
	sync_timer.timeout.connect(_on_sync_timeout)
	if bullet_scene:
		bullet_spawner.add_spawnable_scene(bullet_scene.resource_path)

func _physics_process(delta: float) -> void:

	
	var move_input: Vector2 = input_synchronizer.move_input
	velocity = velocity.move_toward(move_input * speed, acceleration * delta)
	move_and_slide()
	
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("fire"):
			fire_one_shot.rpc("fire_one_shot")

	
	if Input.is_action_just_pressed("test") and is_multiplayer_authority():
		#test.rpc()
		visible = not visible
	
	# animation
	if move_input.x != 0:
		pivot.scale.x = sign(move_input.x)
	
	if not move_input.is_zero_approx() or velocity.length_squared() > 40:
		playback.travel("walk")
	else:
		playback.travel("idle")


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
	camera_2d.enabled = is_multiplayer_authority()

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

func fire() -> void:
	if not is_multiplayer_authority():
		return
	var direction: Vector2 = bullet_spawn_marker.global_position.direction_to(get_global_mouse_position())
	fire_server.rpc_id(1, direction)
	


# this only shoul be called on the server
@rpc("authority", "call_local")
func fire_server(direction: Vector2) -> void:
	if not bullet_scene:
		return
	var bullet_inst: Node2D = bullet_scene.instantiate()
	bullet_inst.global_position = bullet_spawn_marker.global_position
	bullet_inst.global_rotation = direction.angle()
	bullet_spawner.add_child(bullet_inst, true)


@rpc("authority", "call_local", "reliable")
func fire_one_shot(one_shot_name: String) -> void:
	animation_tree["parameters/%s/request" % one_shot_name] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE


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

func get_id() -> int:
	return _data.id


func _on_health_changed(value: int) -> void:
	Debug.log(value)
