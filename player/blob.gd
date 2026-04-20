extends Player

func fire() -> void:
	super.fire()
	velocity -= Vector2.from_angle(pivot.global_rotation + PI) * 100
