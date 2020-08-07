class_name BaseState extends Node

var root: Node
var state_time: float

func init(_root: Node) -> BaseState:
	self.root = _root
	return self

func enter() -> void:
	state_time = 0.0
	pass
	
func leave() -> void:
	pass
	
func process(delta: float) -> String:
	state_time += delta
	return ""
