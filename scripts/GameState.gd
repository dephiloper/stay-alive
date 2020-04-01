extends Node2D

const fire_attack_scene: PackedScene = preload("res://scenes/FireAttack.tscn")

var player = null
var screen_width: float
var screen_height: float
var is_mobile: bool = true


func _init():
	randomize();
	is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"

func _ready() -> void:
	screen_width = get_viewport().get_visible_rect().size.x
	screen_height = get_viewport().get_visible_rect().size.y
	var attack = fire_attack_scene.instance()
	attack.position = Vector2(2000, 2000);
	get_node("/root/Game").add_child(attack)

func register_player(body) -> void:
	player = body
