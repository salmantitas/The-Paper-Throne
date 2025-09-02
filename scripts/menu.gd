extends Node2D

@export var next_scene: PackedScene

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(next_scene)
