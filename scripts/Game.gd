extends Node2D

onready var blob_scene: PackedScene = preload("res://scenes/Blob.tscn")

func _process(_delta: float) -> void:
	$Camera2D.position = $YSort/Player.position
