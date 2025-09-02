class_name State extends Node

# Player reference
static var player : Player

func enter() -> void:
	pass
		
func exit() -> void:
	pass

func state_process(delta: float) -> State:
	return null

func state_physics(delta: float) -> State:
	return null

func handle_input(_event : InputEvent) -> State:
	return null
