extends KinematicBody2D

enum State { IDLE, CHARGE, JUMP, LAND }

const MAX_HEALTH: float = 100.0
const DAMAGE: int = 20
const AGGRO_TIME: float = 5.0
const KNOCKBACK_MULTIPLIER: int = 600

var _recently_hit: bool = false
var _state = State.IDLE

#physics
var _jump_start: Vector2 = Vector2.ZERO
var _target: Vector2 = Vector2.ZERO

# jump physics
const JUMP_DURATION: float = 0.9
const CHARGE_DURATION: float = 2.0
const LAND_DURATION: float = 0.3
const HEIGHT: float = 150.0

var _gravity: float = 0.0
var _jump_speed: float = 0.0
var _time_passed: float = 0.0
var _last_hit_time: float = 0.0
var _jumping = false

func hit(damage: int, force: Vector2 = Vector2.ZERO) -> void:
	$HealthSystem.damage_taken(damage)
	move_and_slide(force) # seems like no good idea to call this here
	_recently_hit = true

func _init() -> void:
	add_to_group("Enemy")
	GameState.blobs.append(self)
	
func _ready() -> void:
	$LandArea.modulate.a = 0.0
	$HealthSystem.setup(MAX_HEALTH)

func _idle() -> void:
	$DamageArea/CollisionShape2D.disabled = true
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
	var accessibility: float = ((1 - y / HEIGHT) + 3) / 4
	$AnimatedSprite.modulate.a = accessibility
	$Shadow.scale = Vector2(0.6 * accessibility, 0.6 * accessibility)
	$AnimatedSprite.position.y = -y

func _land() -> void:
	$CollisionShape2D.disabled = false
	$DamageArea/CollisionShape2D.disabled = false
	position = _target
	_jump_start = Vector2.ZERO
	$LandTween.interpolate_property($LandArea, "scale", Vector2.ZERO, Vector2(0.7, 0.7), 0.10, Tween.TRANS_BACK, Tween.EASE_OUT)
	$LandTween.interpolate_property($LandArea, "modulate", Color("0028539e"), Color("#8028539e"), 0.10, Tween.TRANS_BACK, Tween.EASE_OUT)
	$LandTween.interpolate_property($LandArea, "scale", Vector2(0.7, 0.7), Vector2.ZERO, LAND_DURATION - 0.15, Tween.TRANS_EXPO, Tween.EASE_IN, 0.15)
	$LandTween.interpolate_property($LandArea, "modulate", Color("#8028539e"), Color("0028539e"), LAND_DURATION - 0.15, Tween.TRANS_EXPO, Tween.EASE_IN, 0.15)
	$LandTween.start()
	GameState.camera.shake(0.5)

func _player_in_range() -> bool:
	return position.distance_to(GameState.player.position) < 200

func _process(_delta) -> void:
	$UI.position = $AnimatedSprite.position

func _physics_process(delta) -> void:
	match _state:
		State.IDLE:
			_idle()
			$UI/Label.text = "idle"
			if _player_in_range() or _recently_hit:
				_state = State.CHARGE
				_time_passed = 0
				_charge()
			
		State.CHARGE:
			$UI/Label.text = "charge"
			if _time_passed >= CHARGE_DURATION:
				_target = GameState.player.position + GameState.player.move_direction * 30.0
				_jump_start = position
				_state = State.JUMP
				_time_passed = 0
		
		State.JUMP:
			$UI/Label.text = "jump"
			_jump()
			if _time_passed >= JUMP_DURATION:
				_state = State.LAND
				_time_passed = 0
				_land()
				
		State.LAND:
			$UI/Label.text = "land"
			if _time_passed >= LAND_DURATION:
				_state = State.IDLE
				_time_passed = 0

	_time_passed += delta
	
	if _recently_hit:
		_last_hit_time += delta
	
	if _last_hit_time >= AGGRO_TIME:
		_recently_hit = false
		_last_hit_time = 0.0

func _on_DamageArea_body_entered(body: PhysicsBody2D) -> void:
	if body != null and body.is_in_group("Player"):
		var hit_direction = (body.position - position).normalized() 
		if hit_direction == Vector2.ZERO: hit_direction = Vector2.RIGHT 
		body.hit(DAMAGE, hit_direction * KNOCKBACK_MULTIPLIER)


func _on_HealthSystem_dead() -> void:
	queue_free()
