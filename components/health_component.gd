class_name HealthComponent
extends MultiplayerSynchronizer

signal died
signal health_changed(value: int)

@export var health: int = 50:
	set(value):
		health = clamp(value, 0, max_health) 
		health_changed.emit(health)
		if health == 0:
			died.emit()

@export var max_health: int = 50

func take_damage(damage: int) -> void:
	health -= damage
