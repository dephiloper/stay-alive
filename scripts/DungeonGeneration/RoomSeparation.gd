class_name RoomSeparation extends BaseState

var CHUNK_SIZE := 32
var chunk_index := 0
var collision_appeared := false
var _gen: DungeonGenerator

func init(root: Node) -> BaseState:
	_gen = root as DungeonGenerator
	return .init(root)

func enter() -> void:
	.enter()

func process(delta: float) -> String:
	var state := .process(delta)
	
	for c in range(CHUNK_SIZE):
		var i = c + chunk_index * CHUNK_SIZE
		var roomA := _gen.rooms[i] as Room
		roomA.is_collided = false
		for j in range(len(_gen.rooms)):
			if i == j: continue
			var roomB := _gen.rooms[j] as Room
			
			if roomA.check_for_collision(roomB):
				collision_appeared = true
				roomA.is_collided = true
				roomB.is_collided = true
				var dir := (_gen.rooms[j] as Room).position.direction_to((_gen.rooms[i] as Room).position)
				var new_pos := (_gen.rooms[i] as Room).position + dir * 4
				new_pos += Vector2(rand_range(-1,1), rand_range(-1,1)) * 4
				roomA.position = Vector2(GameState.roundm(new_pos.x, _gen.TILE_SIZE), GameState.roundm(new_pos.y, _gen.TILE_SIZE))
	
	chunk_index += 1
	
	if chunk_index * CHUNK_SIZE == len(_gen.rooms):
		if !collision_appeared:
			print("done")
			state = "MainRoomPicking"
		else:
			collision_appeared = false
			chunk_index = 0
#	for (let i = 0; i < rooms.length; i++) {
#						rooms[i].isCollided = false;
#						for (let j = 0; j < rooms.length; j++) {
#								if (i == j) continue;
#
#								if (rooms[i].checkForCollision(rooms[j])) {
#										rooms[i].isCollided = true;
#										const dir = rooms[j].position.dirTo(rooms[i].position);
#										let newPosition = rooms[i].position.add(dir.mul(delta * 2));
#										newPosition = newPosition.add(new Vector2(Math.random() - 0.5, Math.random() - 0.5).mul(2.5));
#										rooms[i].position = newPosition;
#										rooms[i].position.x = roundm(newPosition.x, TILE_SIZE);
#										rooms[i].position.y = roundm(newPosition.y, TILE_SIZE);
#								}
#						}
#				}
#				tempIndex++;
#
#				if (rooms.every(r => !r.isCollided)) {
#						generationState = State.MainRoomPicking;
#						stateChanged = true;
#						elapsedTime = 0.0;
#						tempIndex = 0;
#						console.log(rooms);
#				}
	
	return state
	
func leave() -> void:
	.leave()
