class_name HallwayGeneration extends BaseState
const room_scene := preload("res://scenes/DungeonGeneration/Room.tscn")
const STATE_STEP_PAUSE := 0.1

var _gen: DungeonGenerator

func init(root: Node) -> BaseState:
	_gen = root as DungeonGenerator
	return .init(root)

func enter() -> void:
	.enter()

func process(delta: float) -> String:
	var state := .process(delta)
	
	if index == len(_gen.hallway_lines):
		return "Done"
	elif state_time > STATE_STEP_PAUSE:
		var a := _gen.hallway_lines[index] as Line2D
		var a_dir := a.points[0].direction_to(a.points[1])
		a.points[0] += Vector2(64, 64)
		a.points[1] += Vector2(64, 64) + (a_dir * 64) # TODO transform to 192
		var b := _gen.hallway_lines[index + 1] as Line2D
		var b_dir := b.points[0].direction_to(b.points[1])
		b.points[0] += Vector2(64, 64) + (b_dir * 64) # TODO transform to 192
		b.points[1] += Vector2(64, 64)
		
		var intersect_point := _find_intersection(a, b) 
		#_create_hallway_room(intersect_point, _gen.TILE_SIZE * 2, _gen.TILE_SIZE * 2)
		_gen.hallways += _create_hallway(a) + _create_hallway(b)
		a.queue_free()
		b.queue_free()
		index += 2
		state_time = 0.0
	
	return state
	
func leave() -> void:
	.leave()
	_gen.hallway_lines.clear()
	var rooms: Array = []
	for r in _gen.rooms:
		if not r.is_main and not r.is_intermediate and not r.is_hallway:
			r.queue_free()
		else:
			rooms.append(r)
	
	_gen.rooms = rooms
	
func _find_intersection(a: Line2D, b: Line2D) -> Vector2:
	if a.points[0] == b.points[0]:
		return a.points[0]
	return a.points[1]

func _create_hallway(l: Line2D) -> Array:
	var hallway: Array = []
	var a := l.points[0]
	var b := l.points[1]
	var dir := (a).direction_to(b)
	var dist := (a).distance_to(b)
	var size := Vector2(dir.y, dir.x).abs() * _gen.TILE_SIZE + Vector2(_gen.TILE_SIZE, _gen.TILE_SIZE)
	var offset := dir * (_gen.TILE_SIZE / 2)
	var tile_count := dist / _gen.TILE_SIZE
	
	var prev: Room
	# go along the line and create a hallway
	for i in range(tile_count):
		var tile_dir := dir * _gen.TILE_SIZE
		var pos := a + i * tile_dir + offset
		var room := _create_hallway_room(pos, size.x, size.y)
		if room:
			room.dir = dir
			hallway.append(room)
			if not prev:
				room.has_door = true

		elif prev and not prev.has_door:
			prev.has_door = true
		prev = room
		
	return hallway

func _create_hallway_room(pos: Vector2, width: float, height: float) -> Room:
	var h: Room = room_scene.instance() as Room
	h.setup(pos, width, height)
	var collided := false
	for room in _gen.rooms:
		var r := room as Room
		if h.id == r.id: continue
		if h.overlaps(r):
			collided = true
			if not r.is_main and not r.is_hallway:
				r.is_intermediate = true
				_gen.intermediate_rooms.append(r)
	
	if collided:
		h = null
	else:
		_gen.rooms.append(h)
		_gen.hallways.append(h)
		_gen.add_child(h)
		h.is_hallway = true
	
	return h
