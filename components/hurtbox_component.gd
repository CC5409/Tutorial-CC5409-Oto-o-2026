class_name HurtboxComponent
extends Area2D

@export var health_component: HealthComponent

func _ready() -> void:
	if multiplayer.is_server():
		area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	var hitbox: HitboxComponent = area as HitboxComponent
	if hitbox and health_component:
		if hitbox.owner == owner:
			return
		health_component.take_damage(hitbox.damage)
		hitbox.damage_dealt.emit()
