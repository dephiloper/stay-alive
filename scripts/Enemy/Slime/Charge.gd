class_name Charge extends BaseState

var _slime: Slime

func init(root: Node) -> BaseState:
	_slime = root as Slime
	return .init(root)

func enter() -> void:
	.enter()
	_slime.sprite.play("land")
	_slime.gravity = 8 * _slime.JUMP_HEIGHT / pow(_slime.JUMP_DURATION, 2)
	_slime.jump_speed = sqrt(2 * _slime.JUMP_HEIGHT * _slime.gravity)

func process(delta: float) -> String:
	var state := .process(delta)
	
	if state_time >= _slime.CHARGE_DURATION:
		state = "jump"
	
	_slime.velocity *= 0.8
	
	return state
	
func leave() -> void:
	.leave()
