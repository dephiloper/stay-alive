extends TextureProgress

const DECREASE_STEP: float = 50.0

var _new_value: float
var _value: float

func _process(delta: float) -> void:
	if _new_value < _value - (DECREASE_STEP * delta):
		_value -= (DECREASE_STEP * delta)
	else:
		_value = _new_value

	value = _value

func _on_HealthSystem_health_updated(health: float, initial: bool) -> void:
	if initial:
		max_value = health
		
	_new_value = health
