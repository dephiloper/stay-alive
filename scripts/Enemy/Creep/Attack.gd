extends BaseState

const creep_attack_scene := preload("res://scenes/Enemy/CreepAttack.tscn")

const ATTACK_SPAWN_DISTANCE := 20

var _creep: Creep

func init(root: Node) -> BaseState:
	_creep = root as Creep
	return .init(root)

func enter() -> void:
	.enter()
	var attack := creep_attack_scene.instance() as CreepAttack
	var attack_direction := _creep.position.direction_to(GameState.player.position + GameState.player.move_direction * 15.0)
	attack.position = _creep.position + attack_direction * ATTACK_SPAWN_DISTANCE
	attack.setup(attack_direction)
	GameState.global_ysort.add_child(attack)

func process(delta: float) -> String:
	var state := .process(delta)
	_creep.velocity *= 0.9
	
	if state_time >= _creep.ATTACK_DURATION:
		state = "idle"
	
	return state
	
func leave() -> void:
	.leave()
