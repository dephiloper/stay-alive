class_name DungeonGenerator extends Node2D

const TILE_SIZE := 64
const ROOM_COUNT := 96
const MAIN_ROOM_COUNT := 12

const ROOM_MIN_DIM := 4 * TILE_SIZE
const ROOM_MAX_DIM := 32 * TILE_SIZE
const ROOM_SPAWN_RADIUS := 96 * TILE_SIZE
const MAIN_ROOM_DIST := 64 * TILE_SIZE
const STATE_PAUSE := 1.0

signal finished_generation(main_rooms, intermediate_rooms, hallways)

onready var _states_map = {
	'RoomGeneration': $States/RoomGeneration.init(self),
	'RoomSeparation': $States/RoomSeparation.init(self),
	'MainRoomPicking': $States/MainRoomPicking.init(self),
	'Triangulation': $States/Triangulation.init(self),
	'GraphGeneration': $States/GraphGeneration.init(self),
	'HallwayRouting': $States/HallwayRouting.init(self),
	'HallwayGeneration': $States/HallwayGeneration.init(self),
}

var rooms: Array = []
var main_rooms: Array = []
var connections: Array = []
var hallway_lines: Array = []
var intermediate_rooms: Array = []
var hallways: Array = []

var _state := 'RoomGeneration'
var _state_time := 0.0
var has_started := false

func _ready() -> void:
	_change_state(_state)
	
func _process(delta: float) -> void:
	if not has_started: return
	
	if _state_time > STATE_PAUSE:
		var state_name = _states_map[_state].process(delta)
		if state_name != "":
			_change_state(state_name)
			
	_state_time += delta

func _change_state(new_state: String) -> void:
	_states_map[_state].leave()

	if new_state == "Done":
		emit_signal("finished_generation", main_rooms, intermediate_rooms, hallways)
		has_started = false
	else:
		_state = new_state
		_states_map[_state].enter()
		_state_time = 0.0
	

	
func get_main_room_coords() -> PoolVector2Array:
	var coords: PoolVector2Array
	for r in main_rooms:
		coords.append((r as Room).position)
	
	return coords
