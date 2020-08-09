class_name RoomGeneration extends BaseState

const room_scene := preload("res://scenes/DungeonGeneration/Room.tscn")

var _gen: DungeonGenerator

func init(root: Node) -> BaseState:
	_gen = root as DungeonGenerator
	return .init(root)

func enter() -> void:
	.enter()
	var center := Vector2(512, 288)
	var coords: Array = _generate_positions_within_circle(center, _gen.ROOM_SPAWN_RADIUS, _gen.ROOM_COUNT)
	_gen.rooms = _generate_rooms(coords)

func process(delta: float) -> String:
	var state := .process(delta)
	
	_gen.add_child(_gen.rooms[index])
	index += 1
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
		x = Algorithms.roundm(x, _gen.TILE_SIZE)
		y = Algorithms.roundm(y, _gen.TILE_SIZE)
		points.append(Vector2(x, y))

	return points

func _generate_rooms(points: Array) -> Array:
	var rooms: Array = []
	for i in range(len(points)):
		var room := room_scene.instance()
		room.setup(i, points[i], 
			Algorithms.roundm(rand_range(_gen.ROOM_MIN_DIM, _gen.ROOM_MAX_DIM), _gen.TILE_SIZE), 
			Algorithms.roundm(rand_range(_gen.ROOM_MIN_DIM, _gen.ROOM_MAX_DIM), _gen.TILE_SIZE))
		rooms.append(room)

	return rooms
