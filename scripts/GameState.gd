extends Node2D

var player = null
var screen_width: float
var screen_height: float

func _ready() -> void:
	screen_width = get_viewport().get_visible_rect().size.x
	screen_height = get_viewport().get_visible_rect().size.y

func register_player(body) -> void:
	player = body
