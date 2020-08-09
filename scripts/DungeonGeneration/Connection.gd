class_name Connection extends Node2D

var a: Room
var b: Room

onready var _line := $Line2D as Line2D

func _ready() -> void:
	_line.points = PoolVector2Array([a.position, b.position])

func equals(o) -> bool:
	return (a.id == o.a.id and b.id == o.b.id) or (a.id == o.b.id and b.id == o.a.id)
