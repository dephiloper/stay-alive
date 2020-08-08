class_name Room extends Node2D

var width: float
var height: float
var is_collided: bool
var rect := RectangleShape2D.new()
onready var area := $Area2D as Area2D

func check_for_collision(o: Room) -> bool:
	return area.overlaps_area(o.area)

func _ready() -> void:
	rect.extents = Vector2(width/2, height/2)
	$Area2D/CollisionShape2D.shape = rect

func _draw() -> void:
	draw_rect(Rect2(-Vector2(width, height)/2, Vector2(width, height)), Color(32, 228, 0), false)
