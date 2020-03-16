extends Node2D

const MOVEMENT_SPEED: int = 500

func _process(delta) -> void:
	$Player.position += $MovementJoystick/TouchScreenButton.get_value() * MOVEMENT_SPEED * delta
