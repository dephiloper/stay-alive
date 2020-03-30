extends KinematicBody2D

onready var fire_spell_scene = preload("res://scenes/FireSpell.tscn")

const MOVEMENT_SPEED: int = 100
const SPELL_SPAWN_DISTANCE_SCALE: int = 20

const MAX_HEALTH: float = 100.0
const MAX_STAMINA: int = 3

var _move_direction: Vector2 = Vector2.ZERO
var _prev_move_direction: Vector2 = Vector2.ZERO
var _aim_direction: Vector2 = Vector2.ZERO
var _health: float
var _stamina: int

func hit(damage: int):
	_change_health(_health - damage)
	
func _on_MovementJoystick_direction_change(dir) -> void:
	_move_direction = dir

func _on_AttackJoystick_stick_released(dir):
	if $StaminaTimer.is_stopped():
		$StaminaTimer.start()
	
	if _stamina == 0: return
	
	if dir == Vector2.ZERO:
		dir = Vector2.UP
	
	var fire_spell = fire_spell_scene.instance()
	fire_spell.position = position + dir.normalized() * SPELL_SPAWN_DISTANCE_SCALE
	fire_spell.setup(dir.normalized())
	get_node("/root/Game/YSort").add_child(fire_spell)
	_change_stamina(_stamina - 1)

func _on_AttackJoystick_direction_change(dir) -> void:
	_aim_direction = dir
	
func _on_StaminaTimer_timeout():
	_change_stamina(_stamina + 1)
	if _stamina < MAX_STAMINA:
		$StaminaTimer.start()

func _init() -> void:
	GameState.register_player(self)	

func _ready() -> void:
	$Sprite.play("idle")
	_change_health(MAX_HEALTH)
	_change_stamina(MAX_STAMINA)

func _process(delta) -> void:
	move_and_slide(_move_direction * MOVEMENT_SPEED)
	if _move_direction != _prev_move_direction:
		_process_animations(_move_direction)
		_prev_move_direction = _move_direction
	
	var relative_aim_dir: Vector2 = position + _aim_direction
	
	if _aim_direction == Vector2.ZERO: 
		$AttackArea.visible = false
	else: 
		$AttackArea.visible = true
		
	$AttackArea.set_rotation(relative_aim_dir.angle_to_point(position))
	
	if _stamina == 0: $AttackArea.color = Color.red
	else: $AttackArea.color = Color.white

func _process_animations(dir) -> void:
	if dir == Vector2.ZERO:
		$Sprite.play("idle")
	else:
		$Sprite.play("walk")
	
		if dir.x > 0: $Sprite.flip_h = true
		else: $Sprite.flip_h = false
	
func _change_health(value: float) -> void:
	_health = min(MAX_HEALTH, max(0.0, value))
	$UI/HealthBar.update_value(_health)

func _change_stamina(value: int) -> void:
	_stamina = min(MAX_STAMINA, max(0.0, value))
	$UI/StaminaBar.update_value(_stamina)
