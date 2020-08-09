class_name Triangulation extends BaseState

const STAGE_STEP_PAUSE := 0.5

var _gen: DungeonGenerator

var _coords: PoolVector2Array
var _triangulation: PoolIntArray

func init(root: Node) -> BaseState:
	_gen = root as DungeonGenerator
	return .init(root)

func enter() -> void:
	.enter()
	for r in _gen.main_rooms:
		_coords.append((r as Room).position)
	
	_coords.invert()
	_triangulation = Geometry.triangulate_delaunay_2d(_coords)
func process(delta: float) -> String:
	var state := .process(delta)
	
	if index == len(_triangulation):
		state = "GraphGeneration"
	elif state_time > STAGE_STEP_PAUSE:
		var a := _coords[_triangulation[index]] as Vector2
		var b := _coords[_triangulation[index+1]] as Vector2
		var c := _coords[_triangulation[index+2]] as Vector2
		_gen.connections.append(_make_line(a, b))
		_gen.connections.append(_make_line(b, c))
		_gen.connections.append(_make_line(c, a))
		index += 3
	
	return state
	
func leave() -> void:
	.leave()
	
func _make_line(a: Vector2, b: Vector2) -> Line2D:
	var line := Line2D.new() as Line2D
	line.width = 1.5
	line.default_color = Color.yellow
	line.points = [a, b]
	_gen.add_child(line)
	return line
