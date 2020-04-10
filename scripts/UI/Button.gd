extends Sprite

signal pressed()
signal released()

export(Vector2) var default_location

const TOUCH_RADIUS: int = 32

var _is_disabled: bool = false
var _debug: bool = false
var _active_finger: int = -1

func _ready() -> void:
	_reset_position()
	_debug = !GameState.is_mobile
	_reset_position()
	if _debug: visible = false

func _process(_delta) -> void:
	if _debug: 
		_emulate_touch()
		
func _input(event) -> void:
	if _is_disabled or _debug: return
	
	if event is InputEventScreenTouch:
		# when stick is pressed
		if event.is_pressed() and _input_in_range(event.position):
			_active_finger = event.get_index()
			emit_signal("pressed")
			
		# when stick is released
		if !event.is_pressed() and _active_finger == event.get_index():
			_active_finger = -1
			emit_signal("released")

# checks if the touch position is inside a specific area 
func _input_in_range(touch_pos: Vector2) -> bool:
	return touch_pos.distance_to(position) < TOUCH_RADIUS
	
# resets the joystick after the touch was released to it's default location
func _reset_position() -> void:
		position.x = default_location.x * GameState.screen_width
		position.y = default_location.y * GameState.screen_height
		
# method for controlling the game with mouse and keyboard
func _emulate_touch() -> void:
	if Input.is_action_just_pressed("dash"):
		emit_signal("pressed")
		print("pressed")
	if Input.is_action_just_released("dash"):
		emit_signal("released")
		print("released")
