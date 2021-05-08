extends Node2D

const DEFAULT_RESOLUTION: Vector2 = Vector2(1024, 576)
var _room_id := 0

var player: Player
var obstacles: Array = []
var camera: Camera2D
var screen_width: float
var screen_height: float
var is_mobile: bool = true
var global_ysort: YSort

func _init():
	randomize()
	is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
	#is_mobile = true
	
func _ready() -> void:
	screen_width = get_viewport().get_visible_rect().size.x
	screen_height = get_viewport().get_visible_rect().size.y
	var zoom_x = DEFAULT_RESOLUTION.x / screen_width
	var zoom_y = DEFAULT_RESOLUTION.y / screen_height
	var zoom = (zoom_x + zoom_y) / 2
	if camera:
		camera.zoom = Vector2(zoom, zoom)

func register_player(_player: PhysicsBody2D) -> void:
	self.player = _player
	
func register_obstacle(obstacle: PhysicsBody2D) -> void:
	self.obstacles.append(obstacle)

func register_camera(_camera: Camera2D) -> void:
	self.camera = _camera

func set_global_ysort(ysort: YSort) -> void:
	self.global_ysort = ysort
	
func player_in_range(pos: Vector2, radius: float) -> bool:
	return pos.distance_to(GameState.player.position) < radius

func new_id() -> int:
	var new_id := _room_id
	_room_id += 1
	return new_id
