class_name Room extends Node2D

var width: float
var height: float
var is_collided: bool

onready var collision_shape := $Area2D/CollisionShape2D as CollisionShape2D
onready var area := $Area2D as Area2D
onready var color_rect := $ColorRect as ColorRect

func check_for_collision(o: Room) -> bool:
	return area.overlaps_area(o.area) #rect.collide(transform, o.rect, o.transform)

#func check_for_collision(o: Room) -> bool:
#	var l1 = position + Vector2(-width / 2, height / 2)
#	var r1 = position + Vector2(width / 2, -height / 2)
#	var l2 = o.position + Vector2(-o.width / 2, o.height / 2)
#	var r2 = o.position + Vector2(o.width / 2, -o.height / 2)
#
#	if l1.x >= r2.x or l2.x >= r1.x:
#		return false
#
#	if l1.y <= r2.y or l2.y <= r1.y:
#		return false
#
#	return true

func setup(_position: Vector2, _width: float, _height: float) -> void:
	position = _position
	width = _width
	height = _height

func _ready() -> void:
	color_rect.rect_size = Vector2(width, height)
	color_rect.rect_position = -Vector2(width/2, height/2)
	var rect_shape := RectangleShape2D.new()
	rect_shape.extents = Vector2(width/2, height/2)
	collision_shape.shape = rect_shape
