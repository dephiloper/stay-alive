extends KinematicBody2D

const SPEED: int = 60
const DAMAGE: int = 20
var _velocity: Vector2 = Vector2.ZERO
var _health: float = 40

func hit(damage: int, force: Vector2 = Vector2.ZERO) -> void:
	if _health - damage > 0:
		_health -= damage
		$DamageTween.interpolate_property(self, "scale", Vector2(0.5, 0.5), Vector2(1, 1), 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		$DamageTween.interpolate_property($AnimatedSprite, "modulate", Color(0.7, 1, 0.7, 1), Color(1, 1, 1, 1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		_velocity += force * 12
		$DamageTween.start()
	else:
		queue_free()

func _physics_process(delta) -> void:
	var direction: Vector2 = GameState.player.position - position
	_velocity += _velocity + direction.normalized() # no good solution imo
	_velocity = _velocity.normalized()
	
	var collision = move_and_collide(_velocity * SPEED * delta)
	
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("hit"):
			collider.hit(DAMAGE)
			queue_free()
