class_name Triangulation extends BaseState

const connection_scene := preload("res://scenes/DungeonGeneration/Connection.tscn")

const STATE_STEP_PAUSE := 0.05

var _gen: DungeonGenerator

func init(root: Node) -> BaseState:
	_gen = root as DungeonGenerator
	return .init(root)

func enter() -> void:
	.enter()
	var triangulation = Geometry.triangulate_delaunay_2d(_gen.get_main_room_coords())
	_gen.connections = _unique_connections(triangulation, _gen.main_rooms)

func process(delta: float) -> String:
	var state := .process(delta)
	
	if index == len(_gen.connections):
		state = "GraphGeneration"
	elif state_time > STATE_STEP_PAUSE:
		_gen.add_child(_gen.connections[index] as Connection)
		index += 1
		state_time = 0
	
	return state
	
func leave() -> void:
	.leave()
	
func _unique_connections(triangulation: PoolIntArray, rooms: Array) -> Array:
	var i: int = 0
	var unique: Array = []
	var connections: Array = []
	while i < len(triangulation):
		var a := triangulation[i] as int
		var b := triangulation[i+1] as int
		var c := triangulation[i+2] as int
		
		if unique.count([a, b]) == 0 and unique.count([b, a]) == 0:
			unique.append([a, b])
		if unique.count([b, c]) == 0 and unique.count([c, b]) == 0:
			unique.append([b, c])
		if unique.count([a, c]) == 0 and unique.count([c, a]) == 0:
			unique.append([a, c])
		i += 3
		
	for u in unique:
		var con := connection_scene.instance()
		con.a = rooms[u[0]] as Room
		con.b = rooms[u[1]] as Room
		connections.append(con)
		
	return connections
