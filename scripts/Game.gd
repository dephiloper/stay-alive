extends Node2D

onready var blob_scene: PackedScene = preload("res://scenes/Blob.tscn")

func _process(_delta: float) -> void:
	$Camera2D.position = $YSort/Player.position

func _on_SpawnTimer_timeout():
	var blob: Node2D = blob_scene.instance()
	blob.position = Vector2(randf() * 1024, randf() * 600)
	add_child(blob)
