class_name Enemy3 extends Enemy1

func _ready() -> void:
	strength = 3
	health_FULL = 8
	gate = $"../Gate3"
	initialize()

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		chase = true

func _on_player_attack_range_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		attack = true
		print("In Attack Range")

func _on_player_attack_range_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		attack = false
		print("Outside Attack Range")

func _on_attack_cooldown_timeout() -> void:
	canAttack = true
	attack_cooldown.stop()

func _on_hit_timer_timeout() -> void:
	hit_timer.stop()
