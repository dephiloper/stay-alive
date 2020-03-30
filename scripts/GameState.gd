extends Node2D

var player = null
var screen_width: float
var screen_height: float
var is_mobile: bool = true

func _init():
	randomize();
	is_mobile = true #OS.get_name() == "Android" or OS.get_name() == "iOS"

func _ready() -> void:
	screen_width = get_viewport().get_visible_rect().size.x
	screen_height = get_viewport().get_visible_rect().size.y

func register_player(body) -> void:
	player = body
