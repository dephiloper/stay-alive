class_name HallwayGeneration extends BaseState
const room_scene := preload("res://scenes/DungeonGeneration/Room.tscn")
const STATE_STEP_PAUSE := 0.05

var _gen: DungeonGenerator

func init(root: Node) -> BaseState:
	_gen = root as DungeonGenerator
	return .init(root)

func enter() -> void:
	.enter()

func process(delta: float) -> String:
	var state := .process(delta)
	
	if index == len(_gen.hallway_lines):
		return ""
	elif state_time > STATE_STEP_PAUSE:
		var a := _gen.hallway_lines[index] as Line2D
		var b := _gen.hallway_lines[index + 1] as Line2D
		
		var intersect_point := _find_intersection(a, b)
		var intersect_hallway := room_scene.instance() as Room
		intersect_hallway.setup(-1, intersect_point, 128, 128)
		_gen.add_child(intersect_hallway)
		_gen.rooms.append(intersect_hallway)
		intersect_hallway.is_hallway = true
		
		_create_hallway(a)
		_create_hallway(b)
		
		index += 2
	
	return state
	
func leave() -> void:
	.leave()
	
func _find_intersection(a: Line2D, b: Line2D) -> Vector2:
	if a.points[0] == b.points[0]:
		return a.points[0]
	return a.points[1]

func _create_hallway(l: Line2D) -> void:
	var a := l.points[0]
	var b := l.points[1]
	var dir := (a).direction_to(b)
	var dist := (a).distance_to(b)
	var size := Vector2(abs(dir.y), abs(dir.x)) * _gen.TILE_SIZE + Vector2(_gen.TILE_SIZE, _gen.TILE_SIZE)
	var offset := dir * (_gen.TILE_SIZE / 2)
	var tile_count := dist / _gen.TILE_SIZE
	for i in range(tile_count):
		var hallway: Room = room_scene.instance() as Room
		var pos := a + i * (dir * _gen.TILE_SIZE) + offset
		hallway.setup(-1, pos , size.x, size.y)

		var shape_a: RectangleShape2D = RectangleShape2D.new() as RectangleShape2D
		shape_a.extents = Vector2(hallway.width / 2, hallway.height / 2)
		#shape_a.position = hallway.position
		
		var colliding := false
		for r in _gen.rooms:
			var room: Room = r as Room
			var shape_b: RectangleShape2D = RectangleShape2D.new() as RectangleShape2D
			shape_b.extents = Vector2(r.width / 2, r.height / 2)
			#shape_b.position = r.position
			if shape_a.collide(hallway.transform, shape_b, r.transform):
				colliding = true
				if not room.is_main:
					room.is_intermediate = true
		
		if not colliding:
			_gen.add_child(hallway)
			_gen.rooms.append(hallway)
			hallway.is_hallway = true
		
