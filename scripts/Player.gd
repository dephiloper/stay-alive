extends KinematicBody2D

export(PackedScene) var attack_area_scene: PackedScene
export(PackedScene) var attack_scene: PackedScene

const MOVEMENT_SPEED: int = 100
const DASH_SPEED: int = 600
const DASH_DURATION: float = 0.15
const ATTACK_SPAWN_DISTANCE: int = 20

const MAX_HEALTH: float = 100.0
const MAX_STAMINA: int = 3

var _dash_left_texture: Texture = preload("res://img/dash/left.png")
var _dash_right_texture: Texture = preload("res://img/dash/right.png")

# player stats
var _stamina: int = MAX_STAMINA
var _velocity: Vector2 = Vector2.ZERO
var _hit_force: Vector2 = Vector2.ZERO

var _attack_area: Node2D

var move_direction: Vector2 = Vector2.ZERO
var _prev_move_direction: Vector2 = Vector2.ZERO
var _attack_direction: Vector2 = Vector2.ZERO
var _attack_pressed: bool = false

var _is_dashing: bool = false
var _elapsed_time: float = 0.0

func hit(damage: int, force: Vector2 = Vector2.ZERO):
	_hit_force = force
	$HealthSystem.damage_taken(damage)
	
func _init() -> void:
	GameState.register_player(self)
	add_to_group("Player")

func _ready() -> void:
	$Sprite.play("idle")
	_change_stamina(_stamina)
	$HealthSystem.setup(MAX_HEALTH)
	_attack_area = attack_area_scene.instance()
	add_child(_attack_area)

func _physics_process(delta: float) -> void:
	_velocity = move_and_slide(_velocity + _hit_force)
	_hit_force = _hit_force * 0.8
	if _hit_force.length() < 10: _hit_force = Vector2.ZERO
	
	if _is_dashing:
		var dash_direction: Vector2 = move_direction
		if dash_direction == Vector2.ZERO:
			dash_direction = Vector2.LEFT
			
		_velocity = dash_direction * DASH_SPEED
		_elapsed_time += delta
		_is_dashing = _elapsed_time <= DASH_DURATION
	else:
		if _elapsed_time > 0: _elapsed_time = 0
		_velocity = move_direction * MOVEMENT_SPEED
	
	_process_particles()
	
	if move_direction != _prev_move_direction:
		_process_animations(move_direction)
		_prev_move_direction = move_direction
	
	_process_attack(_attack_area, _attack_direction, _stamina == 0, _attack_pressed and _attack_direction != Vector2.ZERO)

func _process_particles() -> void:
	$Particles2D.emitting = _is_dashing
	if move_direction.x > 0:
		$Particles2D.texture = _dash_right_texture
	else:
		$Particles2D.texture = _dash_left_texture

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

func _change_stamina(value: int) -> void:
	_stamina = min(MAX_STAMINA, max(0, value))
	$UI/StaminaBar.update_value(_stamina)

func _is_stamina_avaiable() -> bool:
	if $StaminaTimer.is_stopped():
		$StaminaTimer.start()
	
	if _stamina == 0: 
		$UI/StaminaBar.shake()
		return false
		
	return true

func _on_StaminaTimer_timeout() -> void:
	_change_stamina(_stamina + 1)
	if _stamina < MAX_STAMINA:
		$StaminaTimer.start()

func _on_MovementJoystick_direction_change(dir: Vector2) -> void:
	move_direction = dir.normalized()

func _on_AttackJoystick_direction_change(dir: Vector2) -> void:
	_attack_direction = dir

func _on_AttackJoystick_stick_pressed() -> void:
	_attack_pressed = true

func _on_DashButton_pressed() -> void:
	if !_is_stamina_avaiable(): return
	_change_stamina(_stamina - 1)
	_is_dashing = true

func _on_AttackJoystick_stick_released(dir) -> void:
	_attack_pressed = false
	
	if !_is_stamina_avaiable(): return
	_change_stamina(_stamina - 1)
	
	if dir == Vector2.ZERO:
		_is_dashing = true
	else:
		var attack = attack_scene.instance()
		attack.position = position + dir.normalized() * ATTACK_SPAWN_DISTANCE
		attack.setup(dir.normalized())
		$"/root/Game/YSort".add_child(attack)


func _on_HealthSystem_dead() -> void:
	get_tree().reload_current_scene()
