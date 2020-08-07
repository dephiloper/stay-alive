class_name Creep extends KinematicBody2D

const MAX_HEALTH := 50.0
const DAMAGE := 20

onready var states_map = {
	'idle': $States/Idle.init(self),
	'follow': $States/Follow.init(self),
	'dash': $States/Dash.init(self),
	'charge': $States/Charge.init(self),
	'attack': $States/Attack.init(self)
}

var _state := 'idle'
var velocity := Vector2.ZERO
var aggro_time := 0.0
var spawn_point := Vector2.ZERO

onready var label := $Label as Label
onready var sprite := $Sprite as AnimatedSprite
onready var trail := $TrailEffect as Particles2D

func hit(damage: int, force: Vector2 = Vector2.ZERO) -> void:
	$HealthSystem.damage_taken(damage)
	aggro_time = 5.0
	velocity += force
	if _state == 'idle':
		_change_state('follow')

func _init() -> void:
	add_to_group("Enemy")
	
func _ready() -> void:
	$HealthSystem.setup(MAX_HEALTH)
	$Sprite.play("idle")
	_change_state(_state)
	spawn_point = position

func _physics_process(delta) -> void:
	var state_name = states_map[_state].process(delta)
	if state_name != "":
		_change_state(state_name)

	velocity = move_and_slide(velocity)
	_change_look_direction()
	aggro_time = max(aggro_time - delta, 0.0)
	
func _change_state(new_state: String) -> void:
	states_map[_state].leave()
	_state = new_state
	states_map[_state].enter()
	label.text = _state

func _change_look_direction() -> void:
	if velocity.normalized().x > 0.3:
		$Sprite.flip_h = true
	elif velocity.normalized().x < -0.3:
		$Sprite.flip_h = false

func _on_HealthSystem_dead():
	queue_free()
