extends Sprite

const MAX_RADIUS: int = 150

func enable() -> void:
	modulate = Color("A0d99934")
	
func disable() -> void:
	modulate = Color("A0aa3030")

func set_direction(dir: Vector2) -> void:
	position = dir * MAX_RADIUS
