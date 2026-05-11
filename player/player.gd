class_name Player
extends CharacterBody2D

@export var speed: int = 200
@export var acceleration: float = 400
@export var jump_speed: int = 500
@export var bullet_scene: PackedScene
@export var weapon_scenes: Array[PackedScene]
@export var skill_scene: PackedScene
	
var _data: Statics.PlayerData
var current_weapon_index: int = 0
var current_weapon: Weapon

@onready var hud: HUD = $HUD
@onready var sprite_2d: Sprite2D = $Sprite2D
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
@onready var explosion_particle: GPUParticles2D = $ExplosionParticle
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var weapon: Weapon = $WeaponPivot/Weapon
@onready var weapon_spawner: MultiplayerSpawner = $WeaponSpawner
@onready var weapon_spawn_point: Marker2D = $WeaponPivot/WeaponSpawnPoint
@onready var health_bar: ProgressBar = %HealthBar
@onready var skill_cooldown: Timer = $SkillCooldown
@onready var skill_spawner: MultiplayerSpawner = $SkillSpawner


func _ready() -> void:
	for weapon_scene: PackedScene in weapon_scenes:
		if not weapon_scene:
			continue
		weapon_spawner.add_spawnable_scene(weapon_scene.resource_path)
	if skill_scene:
		skill_spawner.add_spawnable_scene(skill_scene.resource_path)
	
	health_component.health_changed.connect(_on_health_changed)
	sync_timer.timeout.connect(_on_sync_timeout)
	if bullet_scene:
		bullet_spawner.add_spawnable_scene(bullet_scene.resource_path)
	
	hud.health_bar.max_value = health_component.max_health
	hud.health_bar.value = health_component.health
	
	health_bar.max_value = health_component.max_health
	health_bar.value = health_component.health
	
	hud.skill_progress_bar.max_value = skill_cooldown.wait_time
	skill_cooldown.timeout.connect(func() -> void: hud.set_skill_progress(0))
	hud.set_skill_progress(0)
	
func _process(_delta: float) -> void:
	if not skill_cooldown.is_stopped():
		hud.set_skill_progress(skill_cooldown.time_left)

func _physics_process(delta: float) -> void:
	
	var move_input: Vector2 = input_synchronizer.move_input
	velocity = velocity.move_toward(move_input * speed, acceleration * delta)
	move_and_slide()
	
	if is_multiplayer_authority():
		
		weapon_pivot.rotation = global_position.direction_to(get_global_mouse_position()).angle()
		
		if Input.is_action_just_pressed("fire"):
			#fire_one_shot.rpc("fire_one_shot")
			get_current_weapon().fire()
		if Input.is_action_just_pressed("explosion"):
			explosion.rpc()
			
		if Input.is_action_just_pressed("skill"):
			skill.rpc_id(1, get_global_mouse_position())

	
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
	set_multiplayer_authority(data.id, false)
	multiplayer_synchronizer.set_multiplayer_authority(data.id, false)
	input_synchronizer.set_multiplayer_authority(data.id, false)
	if is_multiplayer_authority():
		sync_timer.start()
	camera_2d.enabled = is_multiplayer_authority()
	hud.visible = is_multiplayer_authority()
	health_bar.visible = not is_multiplayer_authority()
	
	if multiplayer.is_server():
		current_weapon = weapon_scenes[current_weapon_index].instantiate()
		current_weapon.position = weapon_spawn_point.position
		current_weapon.rotation = weapon_spawn_point.rotation
		weapon_spawn_point.add_child(current_weapon, true)


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
	if not animation_tree["parameters/%s/active" % one_shot_name]:
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
	hud.health_bar.value = value
	health_bar.value = value


@rpc("call_local", "reliable")
func explosion() -> void:
	explosion_particle.emitting = true


func get_current_weapon() -> Weapon:
	return weapon_spawn_point.get_child(0) as Weapon

func get_data() -> Statics.PlayerData:
	return _data


@rpc("call_local", "reliable")
func skill(mouse_position: Vector2) -> void:
	if not skill_cooldown.is_stopped():
		return
	skill_multicast.rpc()
	if skill_scene:
		var skill_inst: Node2D = skill_scene.instantiate()
		skill_inst.global_position = mouse_position
		skill_spawner.add_child(skill_inst, true)

@rpc("any_peer", "call_local", "reliable")
func skill_multicast() -> void:
	skill_cooldown.start()
