class_name Enemy4 extends Enemy1

var anguish_sound_first = false

var time_ran = 0
var acceleration = 1

func _ready() -> void:
	strength = 4
	health_FULL = 7
	gate = $"../Gate4"
	initialize()

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		chase = true
		
		if anguish_sound_first == false:
			anguish_sound_first = true
			$AnguishSound.play()
			$AnguishTimer.wait_time = randf_range(0.5, 1)

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

func _on_anguish_timer_timeout() -> void:
	$AnguishSound.play()
	$AnguishTimer.wait_time = randf_range(0.5, 1)
