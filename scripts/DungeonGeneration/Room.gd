class_name Room extends Node2D

var id: int
var width: float
var height: float
var target_position: Vector2
var is_positioned := false

var is_main: bool setget is_main_set
var is_intermediate: bool setget is_intermediate_set
var is_hallway: bool setget is_hallway_set

onready var color_rect := $ColorRect as ColorRect
onready var center := $CenterPoint as Sprite

func is_main_set(val: bool) -> void:
		is_main = val
		color_rect.color = Color(0, 1, 0, 0.3)
		center.modulate = Color(0, 1, 0, 1)
		center.visible = true

func is_intermediate_set(val: bool) -> void:
		is_intermediate = val
		color_rect.color = Color(1, 0, 0, 0.3)
		
func is_hallway_set(val: bool) -> void:
		is_hallway = val
		color_rect.color = Color(0, 0, 1, 0.3)

func setup(_id: int, _position: Vector2, _width: float, _height: float) -> void:
	id = _id
	position = _position
	width = _width
	height = _height

func _ready() -> void:
	color_rect.rect_size = Vector2(width, height)
	color_rect.rect_position = -Vector2(width/2, height/2)
	
func _process(delta: float) -> void:
	if target_position != Vector2.ZERO:
		var dist = position.distance_to(target_position)
		if dist < 8:
			position = target_position
			target_position = Vector2.ZERO
			is_positioned = true
		else:
			position += position.direction_to(target_position) * delta * dist * 8
