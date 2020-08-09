class_name GraphGeneration extends BaseState
const connection_scene := preload("res://scenes/DungeonGeneration/Connection.tscn")

const STAGE_STEP_PAUSE := 0.2

var _gen: DungeonGenerator
var _unused_connections: Array

func init(root: Node) -> BaseState:
	_gen = root as DungeonGenerator
	return .init(root)

func enter() -> void:
	.enter()
	var mst := Algorithms.prim(_gen.get_main_room_coords()) as PoolIntArray
	var used_connections = _create_used_connections(mst, _gen.main_rooms)
	_unused_connections = _filter_used_connections(_gen.connections, used_connections)
	
func process(delta: float) -> String:
	var state := .process(delta)
	
	if index == len(_unused_connections):
		state = "HallwayRouting"
	elif state_time > STAGE_STEP_PAUSE:
		(_unused_connections[index] as Connection).queue_free()
		index += 1
		state_time = 0
	
	return state
	
func leave() -> void:
	.leave()

func _create_used_connections(arr: PoolIntArray, rooms: Array) -> Array:
	var used_connections: Array = []
	for i in range(0, len(arr), 2):
		var conn := connection_scene.instance() as Connection
		conn.a = rooms[arr[i]] as Room
		conn.b = rooms[arr[i+1]] as Room
		used_connections.append(conn)
	return used_connections

func _filter_used_connections(tri_used_connections: Array, mst_used_connections: Array) -> Array:
	var unused: Array = []
	for tri_conn in tri_used_connections:
		var used := false
		var c1 := tri_conn as Connection
		for mst_conn in mst_used_connections:
			var c2 := mst_conn as Connection
			if c1.equals(c2):
				used = true
				break
		
		if not used:
			unused.append(c1)
	
	return unused
