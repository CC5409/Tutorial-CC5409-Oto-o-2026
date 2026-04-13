extends CharacterBody2D
@onready var health_component: HealthComponent = $HealthComponent

func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)


func _on_health_changed(value: int) -> void:
	Debug.log(value)
