extends Particles2D

const HIT_DIRECTION_OFFSET: int = 25

func setup(pos: Vector2, dir: Vector2) -> void:
	emitting = true
	one_shot = true
	global_position = pos - dir * HIT_DIRECTION_OFFSET
	rotation = dir.angle()


func _on_Timer_timeout():
	queue_free()
