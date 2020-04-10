extends Sprite

enum ButtonType {MOVEMENT, ATTACK, SPECIAL}

# signals
signal direction_change(dir)
signal stick_pressed()
signal stick_released(dir)

export(Color) var joystick_color: Color = Color.white
export(Vector2) var default_location 
export(ButtonType) var button_type 
export(Texture) var icon 

const RADIUS: Vector2 = Vector2(128, 128)
const BOUNDS: int = 224
const JOYSTICK_RETURN_ACCEL: int = 20
const MIN_THRESHOLD: int = 40
const TOUCH_PADDING: int = 272

var _debug: bool
var _ongoing_drag: int = -1
var _prev_dir: Vector2 = Vector2.ZERO
var _active_finger: int = -1
var _is_disabled: bool = false

func _ready() -> void:
	_debug = !GameState.is_mobile
	$TouchButton/Sprite.texture = icon
	$TouchButton.position -= RADIUS
	_reset_position()
	if _debug: visible = false

func _process(delta) -> void:
	if _is_disabled:
		return
		
	var dir: Vector2 = Vector2.ZERO
	
	# input comes from mouse and keyboard events
	if _debug: 
		dir = _emulate_touch()
	else:
		if _ongoing_drag != -1: # user performs drag
			$TouchButton.modulate = Color(joystick_color.r, joystick_color.g, joystick_color.b, 1.0)
		
		else: # when the user is not dragging, move the stick back to it's origin
			var diff_to_center: Vector2 = -RADIUS - $TouchButton.position
			$TouchButton.modulate = Color(joystick_color.r, joystick_color.g, joystick_color.b, 0.5)
			$TouchButton.position += diff_to_center * JOYSTICK_RETURN_ACCEL * delta
			if diff_to_center.length() < 0.1:
				$TouchButton.position = -RADIUS
	
		dir = _calculate_direction()

	if dir != _prev_dir: # direction changed so call signal
		emit_signal("direction_change", dir)
		_prev_dir = dir
	
func _input(event) -> void:
	if _is_disabled or _debug: return
	
	if event is InputEventScreenTouch:
		# when stick is pressed
		if event.is_pressed() and _input_in_range(event.position):
			_active_finger = event.get_index()
			position = _apply_touch_padding(event.position)
			emit_signal("stick_pressed")
			
		# when stick is released
		if !event.is_pressed() and _active_finger == event.get_index():
			_reset_position()
			_active_finger = -1
			if event.get_index() == _ongoing_drag:
				_ongoing_drag = -1
			emit_signal("stick_released", _calculate_direction())
		
	# when stick is dragged
	if event is InputEventScreenDrag:
		# allows the user to drag inside the other screen half without 
		# touching the other buttons
		if (!_input_in_range(event.position) and _ongoing_drag != event.get_index()) or _active_finger == -1:
			return
		
		# set the inner stick position to the corresponding position relative
		# to the users touch location
		$TouchButton.global_position = event.position - RADIUS * $TouchButton.global_scale
		
		# evaluates when the stick is dragged out further than the bounds
		# limits the sticks position to be inside the bounds
		if _get_button_center().length() > BOUNDS:
			$TouchButton.position = _get_button_center().normalized() * BOUNDS - RADIUS
		
		# gets set when a drag occours (evaluates no longer to 0)
		_ongoing_drag = event.get_index()
		
# returns the center of the outer joystick area
func _get_button_center() -> Vector2:
	return $TouchButton.position + RADIUS

# calculates the absolute direction vector of the stick
func _calculate_direction() -> Vector2:
	if _get_button_center().length() > MIN_THRESHOLD:
		return _get_button_center() / BOUNDS
	
	return Vector2.ZERO

# checks if the touch position is inside a specific area 
func _input_in_range(touch_pos: Vector2) -> bool:
	match button_type:
		ButtonType.MOVEMENT:	# movement stick corresponds to left area of the screen
			return touch_pos.x > 0 and touch_pos.x < GameState.screen_width * 0.5
		ButtonType.ATTACK:		# attack stick corresponds to right area of the screen
			return touch_pos.x > GameState.screen_width * 0.5 and touch_pos.x < GameState.screen_width
		ButtonType.SPECIAL: # for special button only check specific radius around the button
			return touch_pos.distance_to(position) < 64
	assert(false)
	return false # this should never happen!

# sets a padding to the game screen to prevent touching on the screen border
func _apply_touch_padding(pos: Vector2) -> Vector2:
	var padding: float = TOUCH_PADDING * $TouchButton.global_scale.x
	
	pos.x = max(padding, min(GameState.screen_width - padding, pos.x))
	pos.y = max(padding, min(GameState.screen_height - padding, pos.y))
	
	return pos

# resets the joystick after the touch was released to it's default location
func _reset_position() -> void:
		position.x = default_location.x * GameState.screen_width
		position.y = default_location.y * GameState.screen_height

# method for controlling the game with mouse and keyboard
func _emulate_touch() -> Vector2:
	var dir: Vector2 = Vector2.ZERO
	var mouse_dir: Vector2 = get_viewport().get_mouse_position() - (get_viewport_rect().size / 2)
	if mouse_dir.length() > 150:
		mouse_dir = mouse_dir.normalized()
	else:
		mouse_dir = mouse_dir / 150
	
	match button_type:
		ButtonType.MOVEMENT:
			if Input.is_action_pressed("left"):		dir.x -= 1
			if Input.is_action_pressed("right"):	dir.x += 1
			if Input.is_action_pressed("up"):			dir.y -= 1
			if Input.is_action_pressed("down"):		dir.y += 1
			dir = dir.normalized()
		ButtonType.ATTACK:
			if Input.is_action_pressed("shoot"):
				dir = mouse_dir
				emit_signal("stick_pressed")
			if Input.is_action_just_released("shoot"):
				emit_signal("stick_released", mouse_dir)
			if Input.is_action_just_released("dash"):
				emit_signal("stick_released", Vector2.ZERO)
		ButtonType.SPECIAL:
			if Input.is_action_pressed("special"):
				emit_signal("stick_pressed")
				dir = mouse_dir
			if Input.is_action_just_released("special"):
				emit_signal("stick_released", mouse_dir)
	
	return dir

#func _on_NeighborButton_pressed() -> void:
#	_is_disabled = true

#func _on_NeighborButton_released() -> void:
#	_is_disabled = false
