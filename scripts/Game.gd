extends Node2D

onready var blob_scene = preload("res://scenes/Blob.tscn")

func _process(delta) -> void:
	$Camera2D.position = $YSort/Player.position

func _on_SpawnTimer_timeout():
	var blob = blob_scene.instance()
	blob.position = Vector2(randf() * 1024, randf() * 600)
	add_child(blob)
