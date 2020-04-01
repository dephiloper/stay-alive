extends Area2D

const MAX_RADIUS: int = 150
const DAMAGE: int = 20

func _ready() -> void:
	position.y -= $AnimatedSprite.position.y

func _process(_delta: float) -> void:
	if !$VisibilityNotifier2D.is_on_screen():
		queue_free()
		
func _on_Timer_timeout() -> void:
	queue_free()
	
func _on_Area2D_body_entered(body):
	pass # Replace with function body.

func _on_Area2D_body_exited(body):
	pass # Replace with function body.
