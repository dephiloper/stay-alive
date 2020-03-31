extends KinematicBody2D

onready var fire_spell_scene = preload("res://scenes/FireSpell.tscn")

export(PackedScene) var attack_area_scene
export(PackedScene) var special_area_scene

const MOVEMENT_SPEED: int = 100
const SPELL_SPAWN_DISTANCE_SCALE: int = 20

const MAX_HEALTH: float = 100.0
const MAX_STAMINA: int = 3

# player stats
var _health: float
var _stamina: int

var _attack_area: Node2D
var _special_area: Node2D

var _move_direction: Vector2 = Vector2.ZERO
var _prev_move_direction: Vector2 = Vector2.ZERO
var _attack_direction: Vector2 = Vector2.ZERO
var _special_direction: Vector2 = Vector2.ZERO
var _attack_pressed: bool = false
var _special_pressed: bool = false

func hit(damage: int):
	_change_health(_health - damage)
	
func _init() -> void:
	GameState.register_player(self)

func _ready() -> void:
	$Sprite.play("idle")
	_change_health(MAX_HEALTH)
	_change_stamina(MAX_STAMINA)
	
	_attack_area = attack_area_scene.instance()
	_special_area = special_area_scene.instance()
	add_child(_attack_area)
	add_child(_special_area)

func _process(delta) -> void:
	move_and_slide(_move_direction * MOVEMENT_SPEED)
	if _move_direction != _prev_move_direction:
		_process_animations(_move_direction)
		_prev_move_direction = _move_direction
	
	_process_attack(_attack_area, _attack_direction, _stamina == 0, _attack_pressed and _attack_direction != Vector2.ZERO)
	_process_attack(_special_area, _special_direction, _stamina == 0, _special_pressed)

func _process_animations(dir: Vector2) -> void:
	if dir != Vector2.ZERO: $Sprite.play("walk")
	else: $Sprite.play("idle")
	
	if dir.x > 0: $Sprite.flip_h = true
	else: $Sprite.flip_h = false

func _process_attack(area: Node2D, dir: Vector2, on_cooldown: bool, is_visible: bool):
	area.visible = is_visible
	area.set_direction(dir)
	
	if on_cooldown: _attack_area.disable()
	else: _attack_area.enable()

func _change_health(value: float) -> void:
	_health = min(MAX_HEALTH, max(0.0, value))
	$UI/HealthBar.update_value(_health)

func _change_stamina(value: int) -> void:
	_stamina = min(MAX_STAMINA, max(0.0, value))
	$UI/StaminaBar.update_value(_stamina)

func _on_StaminaTimer_timeout() -> void:
	_change_stamina(_stamina + 1)
	if _stamina < MAX_STAMINA:
		$StaminaTimer.start()

func _on_MovementJoystick_direction_change(dir) -> void:
	_move_direction = dir

func _on_AttackJoystick_direction_change(dir) -> void:
	_attack_direction = dir

func _on_SpecialJoystick_direction_change(dir) -> void:
	_special_direction = dir

func _on_AttackJoystick_stick_pressed() -> void:
	_attack_pressed = true

func _on_SpecialJoystick_stick_pressed() -> void:
	_special_pressed = true

func _on_AttackJoystick_stick_released(dir) -> void:
	_attack_pressed = false
	
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

func _on_SpecialJoystick_stick_released(dir):
	_special_pressed = false
