extends BaseState

const DASH_SPEED: int = 400
var _creep: Creep
var _dash_direction := Vector2.ZERO

func init(root: Node) -> BaseState:
	_creep = root as Creep
	return .init(root)

func enter() -> void:
	.enter()
	_creep.sprite.frame = 0
	_creep.sprite.stop()
	_creep.trail.emitting = true
	_dash_direction = _creep.position.direction_to(GameState.player.position)
	if randf() > 0.5:
		_dash_direction = Vector2(_dash_direction.y, -_dash_direction.x)
	else:
		_dash_direction = Vector2(-_dash_direction.y, _dash_direction.x)

func process(delta: float) -> String:
	var state := .process(delta)
	_creep.velocity = _dash_direction * DASH_SPEED
	
	if state_time >= _creep.DASH_DURATION:
		state = "charge"
	
	return state
	
func leave() -> void:
	.leave()
