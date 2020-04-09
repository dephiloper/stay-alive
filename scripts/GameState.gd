extends Node2D

const DEFAULT_RESOLUTION: Vector2 = Vector2(1024, 576)

var player: PhysicsBody2D = null
var camera: Camera2D = null
var screen_width: float
var screen_height: float
var is_mobile: bool = true

func _init():
	randomize();
	is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
	#is_mobile = true
	
func _ready() -> void:
	screen_width = get_viewport().get_visible_rect().size.x
	screen_height = get_viewport().get_visible_rect().size.y
	var zoom_x = DEFAULT_RESOLUTION.x / screen_width
	var zoom_y = DEFAULT_RESOLUTION.y / screen_height
	var zoom = (zoom_x + zoom_y) / 2
	camera.zoom = Vector2(zoom, zoom)

func register_player(_player: PhysicsBody2D) -> void:
	player = _player
	
func register_camera(_camera: Camera2D) -> void:
	camera = _camera
