extends KinematicBody2D

const creep_attack_scene = preload("res://scenes/Enemy/CreepAttack.tscn")
var _movement_behavior = preload("res://scripts/Helper/MovementBehavior.gd").new()

enum State { IDLE, FOLLOW, CHARGE, DASH, ATTACK }

# state durations
const IDLE_SPEED: int = 40

const FOLLOW_DURATION: float = 1.5
const FOLLOW_SPEED: int = 70

const CHARGE_DURATION: float = 0.5

const ATTACK_DURATION: float = 0.5

const DASH_DURATION: float = 0.12
const DASH_SPEED: int = 400


const LONG_RANGE: int = 300

const MAX_HEALTH: float = 50.0
const DAMAGE: int = 20
const KNOCKBACK_MULTIPLIER: int = 500
const MAX_DISTANCE_TO_SPAWN: int = 100
const BACK_TO_SPAWN_FORCE: int = 50
const ATTACK_SPAWN_DISTANCE: int = 20

var _recently_hit: bool = false
var _state = State.IDLE
var _follow_location: Vector2 = Vector2.ZERO

var _velocity: Vector2 = Vector2.ZERO
var _spawn_point: Vector2 = Vector2.ZERO
var _aggro_time: float = 0.0
var _dash_direction: Vector2 = Vector2.ZERO

var _elapsed_time: float = 0.0
var _last_hit_time: float = 0.0
var _state_changed: bool = true

func hit(damage: int, force: Vector2 = Vector2.ZERO) -> void:
	$HealthSystem.damage_taken(damage)
	_aggro_time = 5.0
	_velocity += force
	if _state == State.IDLE:
		_change_state(State.FOLLOW)

func _init() -> void:
	add_to_group("Enemy")
	
func _ready() -> void:
	_spawn_point = position
	$HealthSystem.setup(MAX_HEALTH)
	$Sprite.play("idle")

func _physics_process(delta) -> void:
	match _state:
		State.IDLE:
			_idle(delta)
			if _player_in_range(LONG_RANGE):
				_aggro_time = 5.0
			if _aggro_time > 0.0:
				_change_state(State.FOLLOW)
				
		
		State.FOLLOW:
			_follow(delta)
			if _aggro_time <= 0:
				_change_state(State.IDLE)
			if _elapsed_time >= FOLLOW_DURATION:
				_change_state(State.DASH)
		
		State.DASH:
			_dash(delta)
			if _elapsed_time >= DASH_DURATION:
				_change_state(State.CHARGE)
		
		State.CHARGE:
			_charge(delta)
			if _elapsed_time >= CHARGE_DURATION:
				_change_state(State.ATTACK)
		
		State.ATTACK:
			_attack(delta)
			if _elapsed_time >= ATTACK_DURATION:
				_change_state(State.IDLE)

	_elapsed_time += delta
	_aggro_time = max(_aggro_time - delta, 0)
	
	_velocity = move_and_slide(_velocity)
	_change_look_direction()
	print(_aggro_time)

func _player_in_range(distance: int) -> bool:
	return position.distance_to(GameState.player.position) < distance

func _idle(delta: float) -> void:
	if _state_changed:
		_state_changed = false
		$Sprite.play("idle")
	
	$Label.text = "idle"
	_velocity += _movement_behavior.wander(_velocity)
	if _spawn_point.distance_to(position) > MAX_DISTANCE_TO_SPAWN:
		_velocity += position.direction_to(_spawn_point) * BACK_TO_SPAWN_FORCE
		$Label.text = "idle_back"
		
	#_velocity += _movement_behavior.collision_avoidance(position, _velocity, IDLE_SPEED)
	
	if _velocity.length() > IDLE_SPEED:
		_velocity = _velocity.normalized() * IDLE_SPEED

func _follow(delta: float) -> void:
	if _state_changed:
		$Label.text = "follow"
		_state_changed = false
		_follow_location = position
	
	if _follow_location.distance_to(position) < 20:
		_follow_location = GameState.player.position

	_velocity += _movement_behavior.seek(position, _follow_location, _velocity, FOLLOW_SPEED)
	#_velocity += _movement_behavior.collision_avoidance(position, _velocity, FOLLOW_SPEED)
	if _velocity.length() > FOLLOW_SPEED:
		_velocity = _velocity.normalized() * FOLLOW_SPEED

func _dash(delta: float) -> void:
	if _state_changed:
		$Sprite.frame = 0
		$Sprite.stop()
		$Label.text = "dash"
		$TrailEffect.emitting = true
		_state_changed = false
		_dash_direction = position.direction_to(GameState.player.position)
		if randf() > 0.5:
			_dash_direction = Vector2(_dash_direction.y, -_dash_direction.x)
		else:
			_dash_direction = Vector2(-_dash_direction.y, _dash_direction.x)
	
	_velocity = _dash_direction * DASH_SPEED

func _charge(delta: float) -> void:
	if _state_changed:
		$Label.text = "charge"
		_state_changed = false
		$Sprite.play("attack")
		$TrailEffect.emitting = false
		
	_velocity *= 0.9

func _attack(delta: float) -> void:
	if _state_changed:
		$Label.text = "attack"
		_state_changed = false
		var attack = creep_attack_scene.instance()
		var attack_direction = position.direction_to(GameState.player.position + GameState.player.move_direction * 15.0)
		attack.position = position + attack_direction * ATTACK_SPAWN_DISTANCE
		attack.setup(attack_direction)
		$"/root/Game/YSort".add_child(attack)
	
	_velocity *= 0.9
	
func _change_state(state) -> void:
	_state = state
	_state_changed = true
	_elapsed_time = 0

func _change_look_direction() -> void:
	if _velocity.normalized().x > 0.3:
		$Sprite.flip_h = true
	elif _velocity.normalized().x < -0.3:
		$Sprite.flip_h = false

func _on_HealthSystem_dead():
	queue_free()
