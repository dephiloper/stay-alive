extends BaseState

const CHARGE_DURATION: float = 0.3

var _creep: Creep

func init(root: Node) -> BaseState:
	_creep = root as Creep
	return .init(root)

func enter() -> void:
	.enter()
	_creep.sprite.play("attack")

func process(delta: float) -> String:
	var state := .process(delta)
	_creep.velocity *= 0.9
	
	if state_time >= CHARGE_DURATION:
		state = "attack"
	
	return state
	
func leave() -> void:
	.leave()
	_creep.trail.emitting = false
