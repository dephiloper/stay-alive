class_name Room extends Node2D

var width: float
var height: float

func _init(_pos: Vector2, _width: float, _height: float) -> void:
	self.width = _width
	self.height = _height
	self.position = _pos
	
func _ready() -> void:
	update()

func _draw() -> void:
	draw_rect(Rect2(-width/2, -height/2, width, height), Color(0.8, 0.8, 0.8, 0.3))
	draw_line(Vector2(-width / 2, -height / 2), Vector2(width / 2, -height / 2), Color.black, 1.5)
	draw_line(Vector2(width / 2, -height / 2), Vector2(width / 2, height / 2), Color.black, 1.5)
	draw_line(Vector2(width / 2, height / 2), Vector2(-width / 2, height / 2), Color.black, 1.5)
	draw_line(Vector2(-width / 2, height / 2), Vector2(-width / 2, -height / 2), Color.black, 1.5)
