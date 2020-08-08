class_name BaseEnemy extends KinematicBody2D

onready var health_system := $HealthSystem as HealthSystem
onready var collision_shape := $CollisionShape2D as CollisionShape2D
onready var sprite := $Sprite as AnimatedSprite

var velocity := Vector2.ZERO
var spawn_point := Vector2.ZERO
var aggro_time := 0.0

func hit(damage: float, knockback := Vector2.ZERO) -> void:
	health_system.damage_taken(damage)
	velocity += knockback

func change_look_direction() -> void:
	if velocity.normalized().x > 0.3:
		sprite.flip_h = true
	elif velocity.normalized().x < -0.3:
		sprite.flip_h = false

func _ready():
	spawn_point = position

func _on_HealthSystem_dead() -> void:
	queue_free()
