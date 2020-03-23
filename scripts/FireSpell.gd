extends KinematicBody2D

var _speed: float
var _velocity: Vector2 = Vector2.ZERO
var _direction: Vector2
const DAMAGE: int = 20

func setup(direction: Vector2, speed: float = 400):
	_velocity = direction.normalized()
	_speed = speed
	_direction = direction

func _ready() -> void:
	look_at(position + _direction.normalized())
	
func _process(delta) -> void:
	if !$VisibilityNotifier2D.is_on_screen():
		queue_free()
		
func _physics_process(delta) -> void:
	var collision = move_and_collide(_velocity * _speed * delta)

	if collision:
		var collider = collision.get_collider()
		if collider.has_method("hit"):
			collider.hit(DAMAGE, (collision.position - position).normalized())
			queue_free()
