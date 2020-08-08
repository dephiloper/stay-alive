class_name DungeonGenerator extends Node2D

const TILE_SIZE := 4

onready var _states_map = {
	'RoomGeneration': $States/RoomGeneration.init(self),
	'RoomSeparation': $States/RoomSeparation.init(self),
	'MainRoomPicking': $States/MainRoomPicking.init(self),
	'Triangulation': $States/Triangulation.init(self),
	'GraphGeneration': $States/GraphGeneration.init(self),
	'HallwayRouting': $States/HallwayRouting.init(self),
	'HallwayGeneration': $States/HallwayGeneration.init(self)
}

var _state := 'RoomGeneration'
var rooms: Array = [Room]

func _ready() -> void:
	_change_state(_state)

func _physics_process(delta: float) -> void:
	var state_name = _states_map[_state].process(delta)
	if state_name != "":
		_change_state(state_name)

func _change_state(new_state: String) -> void:
	_states_map[_state].leave()
	_state = new_state
	_states_map[_state].enter()
