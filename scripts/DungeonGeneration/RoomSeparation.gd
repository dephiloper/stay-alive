class_name RoomSeparation extends BaseState

const _room_collider_scene := preload("res://scenes/DungeonGeneration/RoomCollider.tscn")
const CHUNK_SIZE := 32

var _gen: DungeonGenerator
var _collision_shapes : Array = []
var _collision_appeared := false
var _chunk_index := 0

func init(root: Node) -> BaseState:
	_gen = root as DungeonGenerator
	return .init(root)

func enter() -> void:
	.enter()
	
	for r in _gen.rooms:
		var room := r as Room
		var col := _room_collider_scene.instance() as RoomCollider
		col.position = room.position
		col.width = room.width
		col.height = room.height
		_gen.add_child(col)
		_collision_shapes.append(col)

func process(delta: float) -> String:
	var state := .process(delta)
	
	for c in range(CHUNK_SIZE):
		var i = c + _chunk_index * CHUNK_SIZE
		var col_a := _collision_shapes[i] as RoomCollider
		var room_a := _gen.rooms[i] as Room
		for j in range(len(_gen.rooms)):
			if i == j: continue
			var col_b := _collision_shapes[j] as RoomCollider
			var room_b := _gen.rooms[j] as Room
			
			if col_a.overlaps_area(col_b):
				_collision_appeared = true
				var dir := col_b.position.direction_to(col_a.position)
				var new_pos := col_a.position + dir * 4
				new_pos += Vector2(rand_range(-1,1), rand_range(-1,1)) * 4
				col_a.position = Vector2(Algorithms.roundm(new_pos.x, _gen.TILE_SIZE), Algorithms.roundm(new_pos.y, _gen.TILE_SIZE))
				room_a.target_position = col_a.position
	
	_chunk_index += 1
	
	if _chunk_index * CHUNK_SIZE == len(_gen.rooms):
		if !_collision_appeared:
			state = "MainRoomPicking"
		else:
			_collision_appeared = false
			_chunk_index = 0
	
	return state
	
func leave() -> void:
	.leave()
	for c in _collision_shapes: 
		c.queue_free()

	_collision_shapes.clear()
