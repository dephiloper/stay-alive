class_name RoomCollider extends Area2D

var width := 0.0
var height := 0.0

onready var collision_shape := $CollisionShape2D as CollisionShape2D

func _ready() -> void:
	var rect_shape := RectangleShape2D.new()
	rect_shape.extents = Vector2(width/2, height/2)
	collision_shape.shape = rect_shape
