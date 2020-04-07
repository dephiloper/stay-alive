extends KinematicBody2D

enum State { IDLE, CHARGE, HOOK, DRAG }

const DAMAGE: int = 20
const AGGRO_TIME: float = 5.0
const KNOCKBACK_MULTIPLIER: int = 600

var MAX_HEALTH: float = 100
var _health: float = MAX_HEALTH
var _recently_hit: bool = false
var _state = State.IDLE

#physics
var _velocity: Vector2 = Vector2.ZERO
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
	_change_health(_health - damage)
	$HitTween.interpolate_property(self, "scale", Vector2(0.7, 0.7), Vector2(1, 1), 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$HitTween.interpolate_property($AnimatedSprite, "modulate", Color(1, 1, 1, 1), Color(1, 0.5, 0.5, 1), 0.2, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$HitTween.interpolate_property($AnimatedSprite, "modulate", Color(1, 0.5, 0.5, 1), Color(1, 1, 1, 1), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.1)
	$HitTween.start()
	
	move_and_slide(force) # seems like no good idea to call this here
	_recently_hit = true

	if _health <= 0:
		queue_free()

func _init() -> void:
	add_to_group("Enemy")
	GameState.blobs.append(self)
	
func _ready() -> void:
	$LandArea.modulate.a = 0.0
	_change_health(_health)

func _player_in_range() -> bool:
	return position.distance_to(GameState.player.position) < 200

func _process(_delta) -> void:
	$UI.position = $AnimatedSprite.position

func _physics_process(delta) -> void:
	pass

func _change_health(value: float) -> void:
	_health = min(MAX_HEALTH, max(0.0, value))
	$UI/HealthBar.update_value(_health)

func _on_DamageArea_body_entered(body: PhysicsBody2D) -> void:
	if body != null and body.is_in_group("Player"):
		var hit_direction = (body.position - position).normalized() 
		if hit_direction == Vector2.ZERO: hit_direction = Vector2.RIGHT 
		body.hit(DAMAGE, hit_direction * KNOCKBACK_MULTIPLIER)
