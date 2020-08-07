extends Area2D

const DAMAGE: int = 5
var _containing_bodies: Array = []

func _ready() -> void:
	scale = Vector2(0.2, 0.2)
	$AppearTween.interpolate_property(self, "scale", scale, Vector2(1.0, 1.0), 0.4, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$AppearTween.start()
	
func _process(_delta: float) -> void:
	if !$VisibilityNotifier2D.is_on_screen():
		queue_free()
		
func _on_FireSpecial_body_entered(body) -> void:
	if body.is_in_group("Enemy"):
		_containing_bodies.append(body)
	
func _on_FireSpecial_body_exited(body) -> void:
	if body.is_in_group("Enemy"):
		_containing_bodies.erase(body)

func _on_AppearTween_tween_completed(_object, _key) -> void:
	$ActiveTimer.start()
	$DamageIntervalTimer.start()

func _on_DisappearTween_tween_completed(_object, _key) -> void:
	queue_free()

func _on_ActiveTimer_timeout() -> void:
	$DisappearTween.interpolate_property(self, "scale", Vector2(1.0, 1.0), Vector2(0.0, 0.0), 0.4, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	$DisappearTween.start()

func _on_DamageIntervalTimer_timeout() -> void:
	if $ActiveTimer.is_stopped():
		$DamageIntervalTimer.stop()
	else:
		for body in _containing_bodies:
			if body.has_method("hit"):
				body.hit(DAMAGE)
