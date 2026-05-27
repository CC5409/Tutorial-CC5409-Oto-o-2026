class_name Enemy
extends CharacterBody2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var detection_area_2d: Area2D = $DetectionArea2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var update_timer: Timer = $UpdateTimer

var speed: int = 50
var target_player: Player

func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	
	if is_multiplayer_authority():
		detection_area_2d.body_entered.connect(_on_body_entered)
		detection_area_2d.body_exited.connect(_on_body_exited)
		update_timer.timeout.connect(_update_target_position)
		navigation_agent_2d.velocity_computed.connect(_on_velocity_computed)
	else:
		set_physics_process(false)

func _physics_process(delta: float) -> void:
	
	if target_player:
		var horizontal_direction = sign(target_player.global_position.x - global_position.x)
		Debug.log(horizontal_direction)
	if navigation_agent_2d.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	
	var next_position: Vector2 = navigation_agent_2d.get_next_path_position()
	var direction: Vector2 = global_position.direction_to(next_position)
	
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.velocity = direction * speed
	else:
		_on_velocity_computed(direction * speed)


func _on_health_changed(value: int) -> void:
	Debug.log(value)


func _on_body_entered(body: Node) -> void:
	var player: Player = body as Player
	if player:
		target_player = player
		_update_target_position()
		update_timer.start()

func _on_body_exited(body: Node) -> void:
	var player: Player = body as Player
	if player and player == target_player:
		target_player = null
		update_timer.stop()

func _update_target_position() -> void:
	if target_player:
		navigation_agent_2d.target_position = target_player.global_position

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
