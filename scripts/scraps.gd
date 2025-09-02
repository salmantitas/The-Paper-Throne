extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var game_manager: Node = %GameManager

func _physics_process(delta: float) -> void:
	sprite.rotation += 0.05

func _on_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		game_manager.addScrap()
		queue_free()
