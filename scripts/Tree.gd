extends StaticBody2D

func _ready():
	$Head.modulate = Color(rand_range(110, 210) / 255.0, rand_range(110, 210) / 255.0, 78 / 255.0)
	$Head.scale = Vector2(rand_range(0.9, 1.1), rand_range(0.8, 1.2))
	$Trunk.scale = Vector2(rand_range(0.9, 1.0), rand_range(0.9, 1.0))
	$Head.flip_h = round(rand_range(0, 2))
	$Trunk.flip_h = round(rand_range(0, 2))
	
