extends TextureProgress

const STEP_SIZE: int = 33

func update_value(val: float) -> void:
	value = val * STEP_SIZE

func shake() -> void:
	$Tween.interpolate_property(self, "rect_position", Vector2(-50, -71), Vector2(-55, -71), 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "rect_position", Vector2(-55, -71), Vector2(-45, -71), 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.1)
	$Tween.interpolate_property(self, "rect_position", Vector2(-45, -71), Vector2(-55, -71), 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.2)
	$Tween.interpolate_property(self, "rect_position", Vector2(-55, -71), Vector2(-50, -71), 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.3)
	$Tween.start()
