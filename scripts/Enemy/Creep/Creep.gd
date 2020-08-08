class_name Creep extends BaseEnemy

const MAX_HEALTH := 50.0
const DAMAGE := 20

const FOLLOW_DURATION: float = 2.0
const DASH_DURATION: float = 0.12
const CHARGE_DURATION: float = 0.3
const ATTACK_DURATION: float = 0.5

onready var _states_map = {
	'idle': $States/Idle.init(self),
	'follow': $States/Follow.init(self),
	'dash': $States/Dash.init(self),
	'charge': $States/Charge.init(self),
	'attack': $States/Attack.init(self)
}

var _state := 'idle'

onready var label := $Label as Label
onready var trail := $TrailEffect as Particles2D

func hit(damage: float, knockback := Vector2.ZERO) -> void:
	.hit(damage, knockback)
	aggro_time = 5.0
	velocity += knockback
	if _state == 'idle':
		_change_state('follow')

func _init() -> void:
	add_to_group("Enemy")
	
func _ready() -> void:
	health_system.setup(MAX_HEALTH)
	sprite.play("idle")
	_change_state(_state)
	spawn_point = position

func _physics_process(delta) -> void:
	var state_name = _states_map[_state].process(delta)
	if state_name != "":
		_change_state(state_name)

	velocity = move_and_slide(velocity)
	.change_look_direction()
	aggro_time = max(aggro_time - delta, 0.0)
	
func _change_state(new_state: String) -> void:
	_states_map[_state].leave()
	_state = new_state
	_states_map[_state].enter()
	label.text = _state
