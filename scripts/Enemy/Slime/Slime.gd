class_name Slime extends BaseEnemy

const MAX_HEALTH: float = 100.0
const DAMAGE: int = 20

const JUMP_HEIGHT: float = 150.0
const KNOCKBACK_MULTIPLIER: int = 600

# state durations
const JUMP_DURATION: float = 0.9
const CHARGE_DURATION: float = 2.0
const LAND_DURATION: float = 0.3

onready var _states_map = {
	'idle': $States/Idle.init(self),
	'charge': $States/Charge.init(self),
	'jump': $States/Jump.init(self),
	'land': $States/Land.init(self)
}

onready var label := $Sprite/UI/Label as Label
onready var damage_area := $DamageArea/CollisionShape2D as CollisionShape2D
onready var shadow := $Shadow as Sprite
onready var tween := $LandTween as Tween
onready var land_area := $LandArea as Sprite

var jump_start: Vector2 = Vector2.ZERO
var target: Vector2 = Vector2.ZERO
var gravity: float = 0.0
var jump_speed: float = 0.0

var _state = 'idle'

func hit(damage: float, knockback := Vector2.ZERO) -> void:
	.hit(damage, knockback)
	aggro_time = 5.0

func _init() -> void:
	add_to_group("Enemy")
	
func _ready() -> void:
	land_area.modulate.a = 0.0
	health_system.setup(MAX_HEALTH)
	_change_state(_state)

func _change_state(new_state: String) -> void:
	_states_map[_state].leave()
	_state = new_state
	_states_map[_state].enter()
	label.text = _state

func _process(_delta) -> void:
	if GameState.player_in_range(position, 200):
		sprite.flip_h = position.direction_to(GameState.player.position).x > 0

func _physics_process(delta) -> void:
	var state_name = _states_map[_state].process(delta)
	if state_name != "":
		_change_state(state_name)

	velocity = move_and_slide(velocity)
	.change_look_direction()
	aggro_time = max(aggro_time - delta, 0.0)

func _on_DamageArea_body_entered(body: PhysicsBody2D) -> void:
	if body != null and body.is_in_group("Player"):
		var hit_direction = (body.position - position).normalized() 
		if hit_direction == Vector2.ZERO: hit_direction = Vector2.RIGHT 
		(body as Player).hit(DAMAGE, hit_direction * KNOCKBACK_MULTIPLIER)
