class_name HallwayRouting extends BaseState

var _generator: DungeonGenerator

func init(root: Node) -> BaseState:
	_generator = root as DungeonGenerator
	return .init(root)

func enter() -> void:
	.enter()

func process(delta: float) -> String:
	var state := .process(delta)
	return state
	
func leave() -> void:
	.leave()
