extends KinematicBody2D

enum State { IDLE, CHARGE, HOOK, DRAG }

# state durations
const HOOK_DURATION: float = 0.9
const CHARGE_DURATION: float = 2.0

const MAX_HEALTH: float = 100.0
const DAMAGE: int = 40
const AGGRO_TIME: float = 5.0
const KNOCKBACK_MULTIPLIER: int = 2000

const HOOK_SPEED: int = 700
const DRAG_SPEED: int = 200

var _recently_hit: bool
var _state = State.IDLE

var _velocity: Vector2 = Vector2.ZERO
var _hook_direction: Vector2 = Vector2.ZERO

var _default_hook_position: Vector2 = Vector2.ZERO
var _elapsed_time: float = 0.0
var _last_hit_time: float = 0.0
var _state_changed: bool = true

func hit(damage: int, force: Vector2 = Vector2.ZERO) -> void:
	$HealthSystem.damage_taken(damage)
	_recently_hit = true

func _init() -> void:
	add_to_group("Enemy")
	
func _ready() -> void:
	_default_hook_position = $Hook.position
	$HealthSystem.setup(MAX_HEALTH)
	$Sprite.play("idle")
	$Hook/Sprite.play("idle")

func _physics_process(delta) -> void:
	match _state:
		State.IDLE:
			_idle()
			if GameState.player_in_range(position, 200) or _recently_hit:
				_change_state(State.CHARGE)
				
		State.CHARGE:
			_charge()
			if _elapsed_time >= CHARGE_DURATION:
				_change_state(State.HOOK)
		
		State.HOOK:
			_hook(delta)
			if _elapsed_time >= HOOK_DURATION:
				_change_state(State.IDLE)

		State.DRAG:
			_drag(delta)
			if GameState.player.position.distance_to(position) < 20.0:
				_attack()
				_change_state(State.IDLE)

	_elapsed_time += delta
	
	if _recently_hit:
		_last_hit_time += delta
	
	if _last_hit_time >= AGGRO_TIME:
		_recently_hit = false
		_last_hit_time = 0.0
		
	update()

func _draw() -> void:
	if _state != State.IDLE:
		draw_line(Vector2(-25, 20), $Hook.position, Color("#222034"), 7.0)

func _idle() -> void:
	if _state_changed:
		_state_changed = false
		$Hook/CollisionPolygon2D.disabled = true
		$UI/Label.text = "idle"
		$Hook.position = _default_hook_position
		$Hook/Sprite.scale = Vector2(0.75, 0.75)
		$Hook.rotation = 0
		
func _charge() -> void:
	if _state_changed:
		_state_changed = false
		$UI/Label.text = "charge"
		$Hook/Sprite.scale = Vector2(1, 1)
	
	$Hook.global_position = position + (GameState.player.position - position).normalized() * 50.0
	$Hook.look_at(GameState.player.position)
	$Hook.rotate(-PI/2)

func _hook(delta: float) -> void:
	if _state_changed:
		_state_changed = false
		$UI/Label.text = "hook"
		_hook_direction = (GameState.player.position - $Hook.global_position).normalized()
		$Hook/CollisionPolygon2D.disabled = false

	$Hook.global_position += _hook_direction * HOOK_SPEED * delta

func _drag(delta: float) -> void:
	if _state_changed:
		_state_changed = false
		$UI/Label.text = "drag"
		GameState.player.paralysed = false
		
	$Hook.global_position += (position - $Hook.global_position).normalized() * DRAG_SPEED * delta
	GameState.player.position = $Hook.global_position

func _attack() -> void:
	GameState.player.is_paralysed = false
	GameState.player.hit(DAMAGE, (GameState.player.position - position).normalized() * KNOCKBACK_MULTIPLIER)

func _change_state(state) -> void:
	_state = state
	_state_changed = true
	_elapsed_time = 0

func _on_HealthSystem_dead():
	queue_free()

func _on_Hook_body_entered(body):
	if body.is_in_group("Player"):
		_state = State.DRAG
		GameState.player.is_paralysed = true
