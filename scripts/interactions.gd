class_name Interactions extends Node2D

@onready var player: Player = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.DirectionChanged.connect( update_directions )

func update_directions( new_direction : int ) -> void:
	match new_direction:
		-1:
			rotation_degrees = 180
		1:
			rotation_degrees = 0
