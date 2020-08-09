extends BaseState

const IDLE_SPEED := 40
const MAX_DISTANCE_TO_SPAWN := 100
const BACK_TO_SPAWN_FORCE := 50
const LONG_RANGE := 300

var _creep: Creep

func init(root: Node) -> BaseState:
	_creep = root as Creep
	return .init(root)

func enter() -> void:
	.enter()
	_creep.sprite.play("idle")

func process(delta: float) -> String:
	var state := .process(delta)
	_creep.velocity += MovementBehavior.wander(_creep.velocity)

	if _creep.spawn_point.distance_to(_creep.position) > MAX_DISTANCE_TO_SPAWN:
		_creep.velocity += _creep.position.direction_to(_creep.spawn_point) * BACK_TO_SPAWN_FORCE
	
	if _creep.velocity.length() > IDLE_SPEED:
		_creep.velocity = _creep.velocity.normalized() * IDLE_SPEED
	
	if GameState.player_in_range(_creep.position, LONG_RANGE):
		_creep.aggro_time = 5.0
	
	if _creep.aggro_time > 0.0:
		state = "follow"
	
	return state
	
func leave() -> void:
	.leave()
