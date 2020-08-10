extends Node2D

func _ready() -> void:
	$DungeonGenerator.has_started = true

func _on_DungeonGenerator_finished_generation(rooms: Array) -> void:
	var rand_room := rooms[randi() % len(rooms)] as Room
	$Tween.interpolate_property($Camera2D, "position", Vector2(0, 0), rand_room.position, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property($Camera2D, "zoom", Vector2(64, 64), Vector2(8, 8), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.5)
	$Tween.start()
	
	for r in rooms:
		var room := r as Room
		var ul := room.position - Vector2(room.width / 2, room.height / 2) + Vector2(32, 32)
		var world = $TileMap.world_to_map(room.position)
		for x in range(0, room.width, 64):
			for y in range(0, room.height, 64):
				var w = $TileMap.world_to_map(ul + Vector2(x, y))
				$TileMap.set_cell(w.x, w.y, 1)
		
		$TileMap.set_cell(world.x, world.y, 0)
		$TileMap.set_cell(world.x-1, world.y, 0)
		$TileMap.set_cell(world.x, world.y-1, 0)
		$TileMap.set_cell(world.x+1, world.y, 0)
		$TileMap.set_cell(world.x, world.y+1, 0)

func _process(delta: float) -> void:
	if Input.is_action_pressed("up"): $Camera2D.position += Vector2.UP * delta * 1000
	if Input.is_action_pressed("down"): $Camera2D.position += Vector2.DOWN * delta * 1000
	if Input.is_action_pressed("left"): $Camera2D.position += Vector2.LEFT * delta * 1000
	if Input.is_action_pressed("right"): $Camera2D.position += Vector2.RIGHT * delta * 1000
	if Input.is_key_pressed(KEY_Q): $Camera2D.zoom += Vector2.ONE * delta * 10
	if Input.is_key_pressed(KEY_E): $Camera2D.zoom -= Vector2.ONE * delta * 10
		
