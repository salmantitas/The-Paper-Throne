extends TextureButton

var default_scale
var default_position
@onready var button: TextureButton = $"."

func _ready() -> void:
	default_scale = button.scale
	default_position = button.position

func _on_pressed() -> void:
	get_tree().reload_current_scene()

func _on_mouse_entered() -> void:
	var scaling = 0.1
		
	button.scale.x += scaling
	button.scale.y += scaling
		
	var offset_x = button.size.x * scaling
	var offset_y = button.size.y * scaling/2
	
	button.position.x += -offset_x
	button.position.y += 0

func _on_mouse_exited() -> void:
	reset()

func reset():
	button.scale = default_scale
	button.position = default_position
