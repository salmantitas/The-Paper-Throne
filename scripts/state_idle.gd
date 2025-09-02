class_name State_Idle extends Node

@onready var walk: Node = $StateMachine/Walk
@onready var attack: Node = $StateMachine/Attack
@onready var dash: Node = $StateMachine/Dash
@onready var heal: Node = $StateMachine/Heal
@onready var block: Node = $StateMachine/Block

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
	if _event.is_action_pressed("attack"):
		print("Attack")
		return attack
	return null
