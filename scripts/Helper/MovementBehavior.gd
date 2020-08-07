class_name MovementBehaviour

const CIRCLE_DISTANCE: float = 20.0
const CIRCLE_RADIUS: float = 50.0
const ANGLE_CHANGE: float = 0.1
const MAX_AVOID_FORCE: float = 100.0

var _wander_angle: float = 0.0

func seek(position: Vector2, target: Vector2, velocity: Vector2, max_velocity: float) -> Vector2:
	var desired_velocity: Vector2 = (target - position).normalized() * max_velocity
	var steering = desired_velocity - velocity
	
	return steering

func wander(velocity: Vector2) -> Vector2:
	var circle_center: Vector2 = velocity.normalized() * CIRCLE_DISTANCE
	var displacement: Vector2 = Vector2.DOWN * CIRCLE_RADIUS
	displacement = _change_angle(displacement, _wander_angle)
	_wander_angle += rand_range(-ANGLE_CHANGE, ANGLE_CHANGE)
	
	var wander_force: Vector2 = circle_center + displacement
	return wander_force

func _change_angle(vector: Vector2, angle: float) -> Vector2:
	vector.x = cos(angle) * vector.length()
	vector.y = sin(angle) * vector.length()
	return vector

func collision_avoidance(position: Vector2, velocity: Vector2, max_velocity: float) -> Vector2:
	var ahead: Vector2 = position + velocity.normalized() * (velocity.length() / max_velocity)
	var ahead2: Vector2 = position + velocity.normalized() * (velocity.length() * 0.5 / max_velocity)
	var avoidance: Vector2 = Vector2.ZERO
	
	var closest_obstacle: PhysicsBody2D = _find_closest_obstacle(position, ahead, ahead2)

	if closest_obstacle != null:
		avoidance.x = ahead.x - closest_obstacle.position.x;
		avoidance.y = ahead.y - closest_obstacle.position.y;
		avoidance = avoidance.normalized() * MAX_AVOID_FORCE
	else:
		avoidance = Vector2.ZERO

	return avoidance

func _find_closest_obstacle(position: Vector2, ahead: Vector2, ahead2: Vector2) -> PhysicsBody2D:
	var closest: PhysicsBody2D = null
	
	for obstacle in GameState.obstacles:
		var collision: bool = _line_intersects_circle(ahead, ahead2, obstacle);
		if collision && (closest == null || position.distance_to(obstacle.position) < position.distance_to(closest.position)):
			closest = obstacle
	
	return closest
	
func _line_intersects_circle(ahead: Vector2, ahead2: Vector2, obstacle: PhysicsBody2D) -> bool:
	return obstacle.position.distance_to(ahead) <= obstacle.radius * 1.5 || obstacle.position.distance_to(ahead2) <= obstacle.radius * 1.5
