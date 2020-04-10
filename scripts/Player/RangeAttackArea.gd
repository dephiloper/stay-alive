extends Sprite

func enable() -> void:
	modulate = Color("60ffffff")
	
func disable() -> void:
	modulate = Color("80aa3030")

func set_direction(dir: Vector2) -> void:
	var relative_direction = position + dir
	set_rotation(relative_direction.angle_to_point(position))
