extends StaticBody2D

const ALPHA_TRANSITION_VALUE: int = 2

func _ready():
	$Top.modulate = Color(rand_range(110, 210) / 255.0, rand_range(110, 210) / 255.0, 78 / 255.0)
	$Top.flip_h = round(rand_range(0, 2))
	$Trunk.flip_h = round(rand_range(0, 2))
	

func _process(delta: float) -> void:
	if $SeeThroughArea2D.overlaps_area(GameState.player.get_node("Area2D")):
		if modulate.a < 0.61: 
			modulate.a = 0.6
		else:
			modulate.a -= ALPHA_TRANSITION_VALUE * delta
	else:
		if modulate.a > 0.99: 
			modulate.a = 1.0
		else: 
			modulate.a += ALPHA_TRANSITION_VALUE * delta
