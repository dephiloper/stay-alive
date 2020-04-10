extends StaticBody2D

const ALPHA_TRANSITION_VALUE: int = 2
var _overlapping_areas: Array = []

var radius setget ,_get_radius

func _init() -> void:
	GameState.obstacles.append(self)

func _ready() -> void:
	$Top.modulate = Color(rand_range(110, 210) / 255.0, rand_range(110, 210) / 255.0, 78 / 255.0)
	$Top.flip_h = round(rand_range(0, 2))
	$Trunk.flip_h = round(rand_range(0, 2))

func _process(delta: float) -> void:
	if len(_overlapping_areas) > 0:
		if modulate.a < 0.61: 
			modulate.a = 0.6
		else:
			modulate.a -= ALPHA_TRANSITION_VALUE * delta
	else:
		if modulate.a > 0.99: 
			modulate.a = 1.0
		else: 
			modulate.a += ALPHA_TRANSITION_VALUE * delta

func _get_radius() -> float:
	var shape: CircleShape2D = $CollisionShape.shape as CircleShape2D
	return shape.radius

func _on_SeeThroughArea2D_area_entered(area: Area2D) -> void:
	_overlapping_areas.append(area)

func _on_SeeThroughArea2D_area_exited(area: Area2D) -> void:
	_overlapping_areas.erase(area)
