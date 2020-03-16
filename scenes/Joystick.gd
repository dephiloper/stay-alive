extends TouchScreenButton

const RADIUS: Vector2 = Vector2(128, 128)
const BOUNDS: int = 224
const TOUCH_START_BOUNDS: int = 384
const JOYSTICK_RETURN_ACCEL: int = 20
const MIN_THRESHOLD: int = 40

var _ongoing_drag: int = -1

func _init() -> void:
	position -= RADIUS

func _process(delta) -> void:
	if _ongoing_drag == -1:
		var diff_to_center = -RADIUS - position
		get_parent().modulate = Color(1, 1, 1, 0.2)
		if diff_to_center.length() > 0.1:
			position += diff_to_center * JOYSTICK_RETURN_ACCEL * delta
		else:
			position = -RADIUS
	else:
		get_parent().modulate = Color(1, 1, 1, 1)
			
func _get_centered_pos() -> Vector2:
	return position + RADIUS

func _input(event) -> void:
	if (event is InputEventScreenTouch and event.is_pressed()) or event is InputEventScreenDrag:
		var touch_to_center_distance: float = (event.position - get_parent().global_position).length()
	
		if touch_to_center_distance <= TOUCH_START_BOUNDS * global_scale.x or event.get_index() == _ongoing_drag:
			global_position = event.position - RADIUS * global_scale
			
			if _get_centered_pos().length() > BOUNDS:
				position = _get_centered_pos().normalized() * BOUNDS - RADIUS
			
			_ongoing_drag = event.get_index()
		
	if event is InputEventScreenTouch and !event.is_pressed() and event.get_index() == _ongoing_drag:
		_ongoing_drag = -1


func get_value() -> Vector2:
	if _get_centered_pos().length() > MIN_THRESHOLD:
		return _get_centered_pos() / BOUNDS
	
	return Vector2.ZERO
