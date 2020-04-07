extends Camera2D

var _shake_intensity: float = 1.0

func _init() -> void:
	GameState.register_camera(self)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		$ShakeTimer.start()
	
	var shake_offset: float = 0.0
	if !$ShakeTimer.is_stopped():
		shake_offset = sin(($ShakeTimer.wait_time - $ShakeTimer.time_left) * 80.0) * 40.0 * _shake_intensity
	else:
		_shake_intensity = 1.0

	self.position = GameState.player.position
	self.position.y += shake_offset

func shake(intensity: float = 1.0) -> void:
	$ShakeTimer.start()
	_shake_intensity = intensity
