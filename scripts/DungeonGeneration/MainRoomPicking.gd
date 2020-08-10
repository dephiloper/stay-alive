class_name MainRoomPicking extends BaseState

const STATE_STEP_PAUSE := 0.05

var _gen: DungeonGenerator

func init(root: Node) -> BaseState:
	_gen = root as DungeonGenerator
	return .init(root)

func enter() -> void:
	.enter()
	_gen.rooms.sort_custom(self, "_sort_rooms_by_area")
	_gen.main_rooms = _select_main_rooms(_gen.rooms)
	
func process(delta: float) -> String:
	var state := .process(delta)
	
	if len(_gen.main_rooms) == index:
		state = "Triangulation"
	elif state_time > STATE_STEP_PAUSE:
		(_gen.main_rooms[index] as Room).is_main = true
		index += 1
		state_time = 0
	
	return state
	
func leave() -> void:
	.leave()
	
	
func _sort_rooms_by_area(a: Room, b: Room) -> bool:
	return a.width * a.height > b.width * b.height
	
func _select_main_rooms(rooms: Array) -> Array:
	var main_rooms : Array = []
	main_rooms.append(rooms[0])
	for a in rooms:
		var big_dist := true
		var room_a := a as Room
		for b in main_rooms:
			var room_b := b as Room
			if room_a.position.distance_to(room_b.position) < _gen.MAIN_ROOM_DIST:
				big_dist = false
				break
		
		if big_dist:
			main_rooms.append(a)
			if len(main_rooms) == _gen.MAIN_ROOM_COUNT:
				break
			
	return main_rooms
