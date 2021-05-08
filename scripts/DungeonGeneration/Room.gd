class_name Room extends Area2D

var id: int
var width: float
var height: float
var target_position: Vector2
var is_positioned := false
var dir: Vector2

var is_main: bool setget is_main_set
var is_intermediate: bool setget is_intermediate_set
var is_hallway: bool setget is_hallway_set
var has_door: bool setget has_door_set

onready var color_rect := $ColorRect as ColorRect
onready var center := $CenterPoint as Sprite
onready var collision_shape := $CollisionShape2D as CollisionShape2D

var overlapping_rooms: Array = []

func is_main_set(val: bool) -> void:
		is_main = val
		color_rect.color = Color(0, 1, 0, 0.3)
		center.modulate = Color(0, 1, 0, 1)
		center.visible = true

func is_intermediate_set(val: bool) -> void:
		is_intermediate = val
		color_rect.color = Color(1, 1, 0, 0.3)
		
func is_hallway_set(val: bool) -> void:
		is_hallway = val
		color_rect.color = Color(0, 0, 1, 0.3)
		
func has_door_set(val: bool) -> void:
		has_door = val
		color_rect.color = Color(0, 1, 1, 0.3)

func setup(_position: Vector2, _width: float, _height: float) -> void:
	add_to_group("room")
	id = GameState.new_id()
	position = _position
	width = _width
	height = _height

func overlaps(o: Room) -> bool:
	var l1 := position + Vector2(-width / 2, height / 2)
	var r1 := position + Vector2(width / 2, -height / 2)
	var l2 := o.position + Vector2(-o.width / 2, o.height / 2)
	var r2 := o.position + Vector2(o.width / 2, -o.height / 2)
	
	if l1.x >= r2.x or l2.x >= r1.x: 
		return false

	if l1.y <= r2.y or l2.y <= r1.y: 
		return false

	return true

func _ready() -> void:
	color_rect.rect_size = Vector2(width, height)
	color_rect.rect_position = -Vector2(width/2, height/2)
	var rect := RectangleShape2D.new() as RectangleShape2D
	rect.extents = Vector2(width, height) / 2
	collision_shape.shape = rect
	
func _process(delta: float) -> void:
	if target_position != Vector2.ZERO:
		var dist = position.distance_to(target_position) as float
		if dist < 4.0:
			position = target_position
			target_position = Vector2.ZERO
			is_positioned = true
		else:
			position += position.direction_to(target_position) * delta * dist * 4

func _on_Room_area_entered(area: Area2D) -> void:
	if area.is_in_group("room"):
		overlapping_rooms.append(area)
		
		#color_rect.color = Color(0.6, 0.1, 0.1, 0.5)

func _on_Room_area_exited(area: Area2D) -> void:
	if area.is_in_group("room"):
		overlapping_rooms.erase(area)
		
		#if len(overlapping_rooms) == 0:
		#	color_rect.color = Color(1, 1, 1, 0.5)
