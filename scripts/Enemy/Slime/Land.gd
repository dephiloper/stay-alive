class_name Land extends BaseState

var _slime: Slime

func init(root: Node) -> BaseState:
	_slime = root as Slime
	return .init(root)

func enter() -> void:
	.enter()
	_slime.sprite.play("land")
	_slime.collision_shape.disabled = false
	_slime.damage_area.disabled = false
	_slime.jump_start = Vector2.ZERO
	_slime.tween.interpolate_property(_slime.land_area, "scale", Vector2.ZERO, Vector2(0.8, 0.8), 0.10, Tween.TRANS_BACK, Tween.EASE_OUT)
	_slime.tween.interpolate_property(_slime.land_area, "modulate", Color("0028539e"), Color("#8028539e"), 0.10, Tween.TRANS_BACK, Tween.EASE_OUT)
	_slime.tween.interpolate_property(_slime.land_area, "scale", Vector2(0.8, 0.8), Vector2.ZERO, _slime.LAND_DURATION - 0.15, Tween.TRANS_EXPO, Tween.EASE_IN, 0.15)
	_slime.tween.interpolate_property(_slime.land_area, "modulate", Color("#8028539e"), Color("0028539e"), _slime.LAND_DURATION - 0.15, Tween.TRANS_EXPO, Tween.EASE_IN, 0.15)
	_slime.tween.start()
	GameState.camera.shake(0.5)

func process(delta: float) -> String:
	var state := .process(delta)
	
	if state_time >= _slime.LAND_DURATION:
		state = "idle"
	
	return state
	
func leave() -> void:
	.leave()
