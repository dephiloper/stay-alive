class_name RoomGeneration extends BaseState

const room_scene := preload("res://scenes/DungeonGeneration/Room.tscn")

var _gen: DungeonGenerator

func init(root: Node) -> BaseState:
	_gen = root as DungeonGenerator
	
	return .init(root)

func enter() -> void:
	.enter()
	var coords: Array = _generate_positions_within_circle(Vector2.ZERO, _gen.ROOM_SPAWN_RADIUS, _gen.ROOM_COUNT)
	_gen.rooms = _generate_rooms(coords)

func process(delta: float) -> String:
	var state := .process(delta)
	
	for i in range(4):
		_gen.add_child(_gen.rooms[index + i])
	index += 4
	state_time = 0
	
	if index == len(_gen.rooms):
		state = "RoomSeparation"
	
	return state
	
func leave() -> void:
	.leave()

# https://stackoverflow.com/questions/5837572/generate-a-random-point-within-a-circle-uniformly/50746409#50746409
# even though this is well explained, didn't understand it fully
func _generate_positions_within_circle(center: Vector2, radius: float, n: float) -> Array:
	var points: Array = []

	for i in range(n):
		var r := radius * sqrt(randf())
		var theta := randf() * 2 * PI
		var x := center.x + r * cos(theta)
		var y := center.y + r * sin(theta)
		x = Algorithms.roundm(x, _gen.TILE_SIZE * 2)
		y = Algorithms.roundm(y, _gen.TILE_SIZE * 2)
		points.append(Vector2(x, y))

	return points

func _generate_rooms(points: Array) -> Array:
	var rooms: Array = []
	for i in range(len(points)):
		var room := room_scene.instance()
		var c := (_gen.ROOM_MAX_DIM - _gen.ROOM_MIN_DIM)
		var w := _gen.ROOM_MIN_DIM + c * pow(randf(), 1.5)
		var h := _gen.ROOM_MIN_DIM + c * pow(randf(), 1.5)
		room.setup(points[i], 
			Algorithms.roundm(w, _gen.TILE_SIZE*4), 
			Algorithms.roundm(h, _gen.TILE_SIZE*4))
		rooms.append(room)

	return rooms
