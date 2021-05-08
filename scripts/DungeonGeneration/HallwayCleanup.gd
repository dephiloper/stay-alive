class_name HallwayCleanup extends BaseState
const STATE_STEP_PAUSE := 0.05

var _gen: DungeonGenerator
var _remove_rooms : Array = []

func init(root: Node) -> BaseState:
	_gen = root as DungeonGenerator
	return .init(root)

func enter() -> void:
	.enter()
	for h in _gen.hallways:
		var hallway := h as Room
		var overlapping_rooms := hallway.overlapping_rooms as Array
		var remove := false
		for room in overlapping_rooms:
			if !room.is_main and !room.is_hallway:
				room.is_intermediate = true
			if room.is_main or room.is_intermediate:
				_remove_rooms.append(hallway)
	
	#for r in _remove_rooms:
	#	_gen.hallways.erase(r)
	#	r.queue_free()
		
func process(delta: float) -> String:
	var state := .process(delta)
	
	return state
	
func leave() -> void:
	.leave()
