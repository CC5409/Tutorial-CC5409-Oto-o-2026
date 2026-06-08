@tool
extends Marker2D

@onready var timer: Timer = $Timer
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

var enemy_scene: PackedScene = preload("res://enemy/enemy.tscn")
var enemy_count: int = 0

@export var radius: float = 50
@export var amount: int = 10
@export var rate: float = 1
@export var use_radius: bool = true

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if multiplayer.is_server():
		timer.timeout.connect(_on_timeout)
		timer.start(1 / rate)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color.WHITE, false, 4)

func try_spawn() -> void:
	if enemy_count >= amount:
		return
		
	var spawn_position: Vector2 = global_position
	
	if use_radius:
		var length: float = randf_range(0, radius)
		var alpha: float = randf_range(0, 2 * PI)
		
		var pos: Vector2 = length * Vector2(cos(alpha), sin(alpha))
		
		spawn_position = global_position + pos
	else:
		var children: Array[Node] = find_children("*", "Node2D")
		var child: Node2D = children.pick_random()
		spawn_position = child.global_position
	
	if check_spawn(spawn_position):
	
		spawn(spawn_position)

func spawn(pos: Vector2) -> void:
	var enemy_inst: Enemy = enemy_scene.instantiate()
	enemy_inst.global_position = pos
	multiplayer_spawner.add_child(enemy_inst, true)
	enemy_count += 1
	enemy_inst.tree_exited.connect(func() -> void: enemy_count -= 1)

func _on_timeout() -> void:
	try_spawn()


func check_spawn(pos: Vector2) -> bool:
	var check_radius: float = Enemy.radius
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	params.collide_with_bodies = true
	params.collide_with_areas = false
	params.collision_mask = 6
	var t: Transform2D = Transform2D.IDENTITY
	t.origin = pos
	params.transform = t
	var circle_shape: CircleShape2D = CircleShape2D.new()
	circle_shape.radius = check_radius
	params.shape = circle_shape
	var results: Array[Dictionary] = space_state.intersect_shape(params)
	for result: Dictionary in results:
		Debug.log(result.collider.name)
	
	return results.size() == 0
