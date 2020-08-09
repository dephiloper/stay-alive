class_name Idle extends BaseState

const IDLE_SPEED := 20
const MAX_DISTANCE_TO_SPAWN := 60
const BACK_TO_SPAWN_FORCE := 30

var _slime: Slime

func init(root: Node) -> BaseState:
	_slime = root as Slime
	return .init(root)

func enter() -> void:
	.enter()
	_slime.sprite.play("idle")
	_slime.damage_area.disabled = true

func process(delta: float) -> String:
	var state := .process(delta)
	_slime.velocity += MovementBehavior.wander(_slime.velocity)
	
	if _slime.spawn_point.distance_to(_slime.position) > MAX_DISTANCE_TO_SPAWN:
		_slime.velocity += _slime.position.direction_to(_slime.spawn_point) * BACK_TO_SPAWN_FORCE
	
	if _slime.velocity.length() > IDLE_SPEED:
		_slime.velocity = _slime.velocity.normalized() * IDLE_SPEED
	
	if GameState.player_in_range(_slime.position, 200) or _slime.aggro_time > 0:
		state = "charge"
	
	_slime.velocity *= 0.8
	
	return state
	
func leave() -> void:
	.leave()
