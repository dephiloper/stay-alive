extends KinematicBody2D

export(PackedScene) var attack_area_scene: PackedScene
export(PackedScene) var special_area_scene: PackedScene
export(PackedScene) var attack_scene: PackedScene
export(PackedScene) var special_scene: PackedScene

const MOVEMENT_SPEED: int = 100
const ATTACK_SPAWN_DISTANCE: int = 20
const SPECIAL_MAX_DISTANCE: int = 150

const MAX_HEALTH: float = 100.0
const MAX_STAMINA: int = 3


# player stats
var _health: float
var _stamina: int

var _attack_area: Node2D
var _special_area: Node2D

var move_direction: Vector2 = Vector2.ZERO
var _prev_move_direction: Vector2 = Vector2.ZERO
var _attack_direction: Vector2 = Vector2.ZERO
var _special_direction: Vector2 = Vector2.ZERO
var _attack_pressed: bool = false
var _special_pressed: bool = false

func hit(damage: int):
	_change_health(_health - damage)
	
func _init() -> void:
	GameState.register_player(self)
	add_to_group("Player")

func _ready() -> void:
	$Sprite.play("idle")
	_change_health(MAX_HEALTH)
	_change_stamina(MAX_STAMINA)
	
	_attack_area = attack_area_scene.instance()
	_special_area = special_area_scene.instance()
	add_child(_attack_area)
	add_child(_special_area)

func _physics_process(_delta: float) -> void:
	move_and_slide(move_direction * MOVEMENT_SPEED)
	if move_direction != _prev_move_direction:
		_process_animations(move_direction)
		_prev_move_direction = move_direction
	
	_process_attack(_attack_area, _attack_direction, _stamina == 0, _attack_pressed and _attack_direction != Vector2.ZERO)
	_process_attack(_special_area, _special_direction, _stamina == 0, _special_pressed)

func _process_animations(dir: Vector2) -> void:
	if dir != Vector2.ZERO: 
		$Sprite.play("walk")
	else: 
		$Sprite.play("idle")
	
	$Sprite.flip_h = dir.x > 0

func _process_attack(area: Node2D, dir: Vector2, on_cooldown: bool, is_visible: bool):
	area.visible = is_visible
	area.set_direction(dir)
	
	if on_cooldown: area.disable()
	else: area.enable()

func _change_health(value: float) -> void:
	_health = min(MAX_HEALTH, max(0.0, value))
	$UI/HealthBar.update_value(_health)

func _change_stamina(value: int) -> void:
	_stamina = min(MAX_STAMINA, max(0, value))
	$UI/StaminaBar.update_value(_stamina)

func _on_StaminaTimer_timeout() -> void:
	_change_stamina(_stamina + 1)
	if _stamina < MAX_STAMINA:
		$StaminaTimer.start()

func _on_MovementJoystick_direction_change(dir) -> void:
	move_direction = dir

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
	
	if _stamina == 0: 
		$UI/StaminaBar.shake()
		return
	
	if dir == Vector2.ZERO:
		dir = Vector2.UP
	
	var attack = attack_scene.instance()
	attack.position = position + dir.normalized() * ATTACK_SPAWN_DISTANCE
	attack.setup(dir.normalized())
	GameState.global_ysort.add_child(attack)
	_change_stamina(_stamina - 1)

func _on_SpecialJoystick_stick_released(dir: Vector2):
	_special_pressed = false
	
	if $StaminaTimer.is_stopped():
		$StaminaTimer.start()
	
	if _stamina == 0: return
	
	var special = special_scene.instance()
	special.position = position + dir * SPECIAL_MAX_DISTANCE
	GameState.global_ysort.add_child(special)
	_change_stamina(_stamina - 1)
