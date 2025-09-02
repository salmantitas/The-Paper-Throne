class_name Enemy5 extends Enemy1

func _ready() -> void:
	strength = 5
	health_FULL = 10
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

func death_sequence():
	game_manager.set_state_win()
