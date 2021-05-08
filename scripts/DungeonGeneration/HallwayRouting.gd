class_name HallwayRouting extends BaseState
const connection_scene := preload("res://scenes/DungeonGeneration/Connection.tscn")

const STATE_STEP_PAUSE := 0.05
var _gen: DungeonGenerator

func init(root: Node) -> BaseState:
	_gen = root as DungeonGenerator
	return .init(root)

func enter() -> void:
	.enter()
	var center := Vector2.ZERO
	for c in _gen.connections:
		# choose route depending on the center
		var a := (c.a as Room).position as Vector2
		var b := (c.b as Room).position as Vector2

		if a.distance_squared_to(center) < b.distance_squared_to(center):
			var temp := a
			a = b
			b = temp
		
		var l1 := Line2D.new()
		l1.width = _gen.TILE_SIZE
		l1.default_color = Color.yellowgreen
		l1.points = [a, Vector2(a.x, b.y)]
		
		var l2 := Line2D.new() as Line2D
		l2.width = _gen.TILE_SIZE
		l2.default_color = Color.yellowgreen
		l2.points = [Vector2(a.x, b.y), b]
		
		if abs(a.x - center.x) > abs(a.y - center.y):
			l1.points.set(1, Vector2(b.x, a.y))
			l2.points.set(0, Vector2(b.x, a.y))
			
		_gen.hallway_lines.append(l1)
		_gen.hallway_lines.append(l2)

func process(delta: float) -> String:
	var state := .process(delta)
	
	if index == len(_gen.hallway_lines):
		state = "HallwayGeneration"
	elif state_time > STATE_STEP_PAUSE:
		(_gen.connections[index / 2] as Connection).visible = false
		
		_gen.add_child(_gen.hallway_lines[index] as Line2D)
		_gen.add_child(_gen.hallway_lines[index + 1] as Line2D)
		index += 2
	
	return state
	
func leave() -> void:
	.leave()
