class_name RoomGeneration extends BaseState

const ROOM_SPAWN_RADIUS := 48
const ROOM_COUNT := 128
const TILE_SIZE := 4
const ROOM_MIN_DIM := 6
const ROOM_MAX_DIM := 64

const STAGE_STEP_PAUSE := 0.1
const STAGE_PAUSE := 1.0

var _generator: DungeonGenerator
var _state_started := false 

func init(root: Node) -> BaseState:
	_generator = root as DungeonGenerator
	return .init(root)

func enter() -> void:
	.enter()
	var center := Vector2(512, 288)
	var coords: Array = _generate_positions_within_circle(center, ROOM_SPAWN_RADIUS, ROOM_COUNT)
	_generator.rooms = _generate_rooms(coords)

func process(delta: float) -> String:
	var state := .process(delta)
	
	if not _state_started and state_time > STAGE_PAUSE:
		_state_started = true
	
	if _state_started:
		if state_time > STAGE_STEP_PAUSE:
			_generator.add_child(_generator.rooms[index])
			index += 1
		
		if index == len(_generator.rooms):
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
		x = GameState.roundm(x, TILE_SIZE)
		y = GameState.roundm(y, TILE_SIZE)
		points.append(Vector2(x, y))

	return points

func _generate_rooms(points: Array) -> Array:
	var rooms: Array = []
	for p in points:
		var room := Room.new(p, GameState.roundm(rand_range(ROOM_MIN_DIM, ROOM_MAX_DIM), TILE_SIZE), GameState.roundm(rand_range(ROOM_MIN_DIM, ROOM_MAX_DIM), TILE_SIZE)) as Room
		rooms.append(room)

	return rooms
