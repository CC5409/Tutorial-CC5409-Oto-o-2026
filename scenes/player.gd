class_name Player
extends CharacterBody2D

@export var speed: int = 200
@export var acceleration: float = 400
@export var jump_speed: int = 500

@onready var sprite_2d: Sprite2D = $Sprite2D


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump_speed
	
	var move_input: float = Input.get_axis("move_left", "move_right")
	velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
	move_and_slide()

func change_color() -> void:
	sprite_2d.modulate = Color.RED
