extends Node2D

signal health_updated(health, initial)
signal dead()

var _max_health: float
var _health: float

func setup(max_health: float):
	_max_health = max_health
	_health = max_health
	emit_signal("health_updated", _max_health, true)

func damage_taken(damage: float) -> void:
	_change_health(_health - damage)
	$HitTween.interpolate_property(get_parent(), "scale", Vector2(0.7, 0.7), Vector2(1, 1), 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$HitTween.interpolate_property(get_parent(), "modulate", Color(1, 1, 1, 1), Color(1, 0.5, 0.5, 1), 0.2, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$HitTween.interpolate_property(get_parent(), "modulate", Color(1, 0.5, 0.5, 1), Color(1, 1, 1, 1), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.1)
	$HitTween.start()

func _change_health(value: float) -> void:
	_health = min(_max_health, max(0.0, value))
	emit_signal("health_updated", _health, false)
	
	if _health <= 0.0:
		emit_signal("dead")
