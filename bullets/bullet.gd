class_name Bullet
extends Area2D

@export var speed: int = 400


func _ready() -> void:
	await get_tree().create_timer(1).timeout
	if is_multiplayer_authority():
		queue_free()

func _physics_process(delta: float) -> void:
	var direction: Vector2 = global_transform.x
	global_position += direction * speed * delta
