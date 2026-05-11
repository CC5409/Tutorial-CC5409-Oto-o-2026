extends Area2D

@export var damage: int = 10

func _ready() -> void:
	pass

func explode()-> void:
	if not multiplayer.is_server():
		return
	var areas: Array[Area2D] = get_overlapping_areas()
	for area: Area2D in areas:
		var hurtbox: HurtboxComponent = area as HurtboxComponent
		if hurtbox:
			var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
			# use global coordinates, not local to node
			var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, hurtbox.global_position)
			query.collide_with_bodies = true
			query.collide_with_areas = true
			var result: Dictionary = space_state.intersect_ray(query)
			if result:
				Debug.log(result.collider)
			if result and result.collider == hurtbox:
				hurtbox.take_damage(damage)
	
