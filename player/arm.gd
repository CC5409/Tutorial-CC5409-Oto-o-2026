extends Skeleton2D

@onready var marker_2d: Marker2D = $Marker2D

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		marker_2d.global_position = get_global_mouse_position()
