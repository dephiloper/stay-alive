extends Sprite

enum ScreenSide {LEFT, RIGHT}

signal direction_change(dir)
signal stick_released(dir)

onready var touch_button: TouchScreenButton = $TouchButton

export(Color) var joystick_color: Color = Color.white
export(Vector2) var default_location 
export(ScreenSide) var screen_side 

const RADIUS: Vector2 = Vector2(128, 128)
const BOUNDS: int = 224
const TOUCH_START_BOUNDS: int = 448
const JOYSTICK_RETURN_ACCEL: int = 20
const MIN_THRESHOLD: int = 40
const TOUCH_MARGIN: int = 272

var _debug: bool
var _ongoing_drag: int = -1
var _prev_dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	_debug = !GameState.is_mobile
	touch_button.position -= RADIUS
	_reset_joystick()
	if _debug: visible = false

func _process(delta) -> void:
	var dir: Vector2 = Vector2.ZERO
	
	if _debug:
		dir = _emulate_touch()
	else:
		if _ongoing_drag == -1:
			var diff_to_center = -RADIUS - touch_button.position
			touch_button.modulate = Color(joystick_color.r, joystick_color.g, joystick_color.b, 0.2)
			if diff_to_center.length() > 0.1:
				touch_button.position += diff_to_center * JOYSTICK_RETURN_ACCEL * delta
			else:
				touch_button.position = -RADIUS
		else:
			touch_button.modulate = Color(joystick_color.r, joystick_color.g, joystick_color.b, 1.0)
		dir = _get_value()

	if dir != _prev_dir:
		emit_signal("direction_change", dir)
		_prev_dir = dir
	
func _get_centered_pos() -> Vector2:
	return touch_button.position + RADIUS

func _input(event) -> void:
	if _debug: return
	# first touch interaction
	if event is InputEventScreenTouch and event.is_pressed() and _input_in_range(event.position):
		position = _apply_margin(event.position)
		 
	if event is InputEventScreenDrag: # screen drag
		var touch_to_center_distance: float = (event.position - global_position).length()
	
		if touch_to_center_distance <= TOUCH_START_BOUNDS * touch_button.global_scale.x \
		or event.get_index() == _ongoing_drag:
			touch_button.global_position = event.position - RADIUS * touch_button.global_scale
			
			if _get_centered_pos().length() > BOUNDS:
				touch_button.position = _get_centered_pos().normalized() * BOUNDS - RADIUS
			
			_ongoing_drag = event.get_index()
		
	if event is InputEventScreenTouch and !event.is_pressed():
		_reset_joystick()
		if event.get_index() == _ongoing_drag:
			_ongoing_drag = -1
			emit_signal("stick_released", _get_value())

func _get_value() -> Vector2:
	if _get_centered_pos().length() > MIN_THRESHOLD:
		return _get_centered_pos() / BOUNDS
	
	return Vector2.ZERO

func _input_in_range(pos: Vector2) -> bool:
	if screen_side == ScreenSide.LEFT:
		return pos.x > 0 and pos.x < GameState.screen_width * 0.5
	else:
		return pos.x > GameState.screen_width * 0.5 and pos.x < GameState.screen_width

func _apply_margin(pos: Vector2) -> Vector2:
	var margin: float = TOUCH_MARGIN * touch_button.global_scale.x
	
	pos.x = max(margin, min(GameState.screen_width - margin, pos.x))
	pos.y = max(margin, min(GameState.screen_height - margin, pos.y))
	
	return pos

func _reset_joystick() -> void:
		position.x = default_location.x * GameState.screen_width
		position.y = default_location.y * GameState.screen_height
		
func _emulate_touch() -> Vector2:
	var dir: Vector2 = Vector2.ZERO
	if screen_side == ScreenSide.LEFT:
		if Input.is_action_pressed("left"):		dir.x -= 1
		if Input.is_action_pressed("right"):	dir.x += 1
		if Input.is_action_pressed("up"):			dir.y -= 1
		if Input.is_action_pressed("down"):		dir.y += 1
	else:
		dir = get_viewport().get_mouse_position() - (get_viewport_rect().size / 2)
		if Input.is_action_just_pressed("shoot"):	emit_signal("stick_released", dir)
	return dir.normalized()
			
