extends Camera2D

func _process(delta: float) -> void:
	$Label.text = str(Engine.get_frames_per_second())
