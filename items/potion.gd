extends ItemData

@export var health: int = 10

func action(player:  Player) -> void:
	player.health_component.health += health
