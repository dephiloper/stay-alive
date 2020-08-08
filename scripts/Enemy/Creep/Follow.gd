extends BaseState

var _movement_behavior = preload("res://scripts/Helper/MovementBehavior.gd").new()

const FOLLOW_SPEED := 70

var _creep: Creep
var _follow_location := Vector2.ZERO

func init(root: Node) -> BaseState:
	_creep = root as Creep
	return .init(root)

func enter() -> void:
	.enter()
	_follow_location = _creep.position

func process(delta: float) -> String:
	var state = .process(delta)
	if _follow_location.distance_to(_creep.position) < 20:
		_follow_location = GameState.player.position
		
	_creep.velocity += _movement_behavior.seek(_creep.position, _follow_location, _creep.velocity, FOLLOW_SPEED)
	if _creep.velocity.length() > FOLLOW_SPEED:
		_creep.velocity = _creep.velocity.normalized() * FOLLOW_SPEED
	
	if _creep.aggro_time <= 0:
		state = "idle"
	elif state_time >= _creep.FOLLOW_DURATION:
		state = "dash"
	
	return state
	
func leave() -> void:
	.leave()
