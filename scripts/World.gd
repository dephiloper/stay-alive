extends Node2D

func _ready() -> void:
	$DungeonGenerator.has_started = true

func _on_DungeonGenerator_finished_generation(main_rooms: Array, intermediate_rooms: Array, hallways: Array) -> void:
	#var rand_room := rooms[randi() % len(rooms)] as Room
	$DungeonGenerator.queue_free()
	#$Tween.interpolate_property($Camera2D, "position", Vector2(0, 0), rand_room.position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	#$Tween.interpolate_property($Camera2D, "zoom", Vector2(64, 64), Vector2(8, 8), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.5)
	#$Tween.start()
	
	var rooms = main_rooms + intermediate_rooms
	for r in rooms:
		var room := r as Room
		var ul := room.position - Vector2(room.width / 2, room.height / 2) + Vector2(32, 32)
		var world = $TileMap.world_to_map(room.position)
		for x in range(0, room.width, 64):
			for y in range(0, room.height, 64):
				var w = $TileMap.world_to_map(ul + Vector2(x, y))
				if x == 0: # left side
					if y == 0: # top left corner
						$TileMap.set_cell(w.x, w.y, 0)
					elif y == room.height - 64: # bottom left corner
						$TileMap.set_cell(w.x, w.y, 6)
					else:
						$TileMap.set_cell(w.x, w.y, 3)
				
				elif x == room.width - 64: # right side
					if y == 0: # top right corner
						$TileMap.set_cell(w.x, w.y, 2)
					elif y == room.height - 64: # bottom right corner
						$TileMap.set_cell(w.x, w.y, 8)
					else:
						$TileMap.set_cell(w.x, w.y, 5)
						
				elif y == 0:
					$TileMap.set_cell(w.x, w.y, 1)
				
				elif y == room.height - 64:
					$TileMap.set_cell(w.x, w.y, 7)
				
				else:
					$TileMap.set_cell(w.x, w.y, 4)
	
	for r in hallways:
		var room := r as Room
		var ul := room.position - Vector2(room.width / 2, room.height / 2) + Vector2(32, 32)
		var world = $TileMap.world_to_map(room.position)
		for x in range(0, room.width, 64):
			for y in range(0, room.height, 64):
				var w := $TileMap.world_to_map(ul + Vector2(x, y)) as Vector2
				if x == 0 and abs(room.dir.y) > 0: # vertical
					$TileMap.set_cell(w.x, w.y, 3)
				elif x == room.width - 64 and abs(room.dir.y) > 0: # vertical
					$TileMap.set_cell(w.x, w.y, 5)
				elif y == 0 and abs(room.dir.x) > 0: # horizontal
					$TileMap.set_cell(w.x, w.y, 1)
				elif y == room.height - 64 and abs(room.dir.x) > 0: # horizontal
					$TileMap.set_cell(w.x, w.y, 7)
				else:
					$TileMap.set_cell(w.x, w.y, 4)

func _is_room(x: float, y: float) -> bool:
	return $TileMap.get_cell(x, y) == 1

func _process(delta: float) -> void:
	if Input.is_action_pressed("up"): $Camera2D.position += Vector2.UP * delta * 1000
	if Input.is_action_pressed("down"): $Camera2D.position += Vector2.DOWN * delta * 1000
	if Input.is_action_pressed("left"): $Camera2D.position += Vector2.LEFT * delta * 1000
	if Input.is_action_pressed("right"): $Camera2D.position += Vector2.RIGHT * delta * 1000
	if Input.is_key_pressed(KEY_Q): $Camera2D.zoom += Vector2.ONE * delta * 10
	if Input.is_key_pressed(KEY_E): $Camera2D.zoom -= Vector2.ONE * delta * 10
