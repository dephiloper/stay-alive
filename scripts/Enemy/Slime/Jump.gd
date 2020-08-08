class_name Jump extends BaseState

var _slime: Slime
var _target: Vector2
var _jump_start: Vector2

func init(root: Node) -> BaseState:
	_slime = root as Slime
	return .init(root)

func enter() -> void:
	.enter()
	_slime.velocity = Vector2.ZERO
	_slime.sprite.play("jump")
	_target = GameState.player.position + GameState.player.move_direction * 30.0
	_jump_start = _slime.position
	_slime.collision_shape.disabled = true

func process(delta: float) -> String:
	var state := .process(delta)
	
	var y: float = - 0.5 * _slime.gravity * pow(state_time, 2) + _slime.jump_speed * state_time
	var travelled_distance = state_time * _target.distance_to(_jump_start) / _slime.JUMP_DURATION
	_slime.position = _jump_start + _jump_start.direction_to(_target) * travelled_distance
	var accessibility: float = ((1 - y / _slime.JUMP_HEIGHT) + 3) / 4
	_slime.sprite.modulate.a = accessibility
	_slime.shadow.scale = Vector2(0.7 * accessibility, 0.7 * accessibility)
	_slime.sprite.position.y = -y
	
	if state_time >= _slime.JUMP_DURATION:
		state = "land"
	
	return state
	
func leave() -> void:
	.leave()
