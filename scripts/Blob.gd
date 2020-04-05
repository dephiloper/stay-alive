extends KinematicBody2D

enum State { IDLE, CHARGE, JUMP, LAND }

const DAMAGE: int = 20
const AGGRO_TIME: float = 4.0

var _health: float = 200
var _recently_hit: bool = false
var _state = State.IDLE

#physics
var _velocity: Vector2 = Vector2.ZERO
var _jump_start: Vector2 = Vector2.ZERO
var _target: Vector2 = Vector2.ZERO

# jump physics
const HEIGHT: float = 150.0
const JUMP_DURATION: float = 0.8

var _gravity: float = 0.0
var _jump_speed: float = 0.0
var _time_passed: float = 0.0
var _last_hit_time: float = 0.0
var _jumping = false

func hit(damage: int, force: Vector2 = Vector2.ZERO) -> void:
	if _health - damage > 0:
		_health -= damage
		$DamageTween.interpolate_property(self, "scale", Vector2(0.7, 0.7), Vector2(1, 1), 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		$DamageTween.interpolate_property($AnimatedSprite, "modulate", Color(0.7, 1, 0.7, 1), Color(1, 1, 1, 1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		_velocity += force * 12
		$DamageTween.start()
		_recently_hit = true
	else:
		queue_free()

func _init() -> void:
	add_to_group("Enemy")

func _idle() -> void:
	$AnimatedSprite.play("default")
	
func _charge() -> void:
	$AnimatedSprite.stop()
	$AnimatedSprite.frame = 1
	_gravity = 8 * HEIGHT / (pow(JUMP_DURATION, 2))
	_jump_speed = sqrt(2 * HEIGHT * _gravity)

func _jump() -> void:
	$AnimatedSprite.frame = 0
	$CollisionShape2D.disabled = true
	var y: float = - 0.5 * _gravity * pow(_time_passed, 2) + _jump_speed * _time_passed
	var travelled_distance = _time_passed * _target.distance_to(_jump_start) / JUMP_DURATION
	position = _jump_start + _jump_start.direction_to(_target) * travelled_distance
	#position.y -= y
	var accessibility: float = ((1 - y / HEIGHT) + 3) / 4
	$AnimatedSprite.modulate.a = accessibility
	$Shadow.scale = Vector2(0.6 * accessibility, 0.6 * accessibility)
	$AnimatedSprite.position.y = -y

func _land() -> void:
	$CollisionShape2D.disabled = false
	position = _target
	_jump_start = Vector2.ZERO

func _player_in_range() -> bool:
	return position.distance_to(GameState.player.position) < 200

func _physics_process(delta) -> void:
	match _state:
		State.IDLE:
			_idle()
			$Label.text = "idle"
			if _player_in_range() or _recently_hit:
				_state = State.CHARGE
				_time_passed = 0
				_charge()
			
		State.CHARGE:
			$Label.text = "charge"
			if _time_passed >= 1.0:
				_target = GameState.player.position + GameState.player.move_direction * 20.0
				_jump_start = position
				position
				_state = State.JUMP
				_time_passed = 0
		
		State.JUMP:
			$Label.text = "jump"
			_jump()
			if _time_passed >= JUMP_DURATION:
				_state = State.LAND
				_time_passed = 0
				
		State.LAND:
			$Label.text = "land"
			_land()
			if _time_passed >= 1.0:
				_state = State.IDLE
				_time_passed = 0

	_time_passed += delta
	
	if _recently_hit:
		_last_hit_time += delta
	
	if _last_hit_time >= AGGRO_TIME:
		_recently_hit = false
		_last_hit_time = 0.0
