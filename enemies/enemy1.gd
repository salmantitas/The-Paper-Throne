class_name Enemy1 extends CharacterBody2D

var SPEED = 200.0
var direction

var player
var alive = true
var chase = false
var attack = false
var canAttack
var damageDealt = false
var damage_dealt_player = false

var health : float
var health_FULL : float
var strength

var attack_frame

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: Node = %GameManager
@onready var attack_cooldown : Timer
@onready var hit_timer: Timer

var gate

func _ready() -> void:
	strength = 1
	health_FULL = 10
	gate = $"../Gate1"
	
	initialize()

func initialize():
	health = health_FULL
	update_label()
	attack_cooldown = $AttackCooldown
	hit_timer = $HitTimer
	canAttack = true
	$DamageTaken.hide()
	attack_frame = anim.sprite_frames.get_frame_count("attack") - 1
	$AttackSound.volume_db = -15
	$DeathSound.volume_db = -10
	
func _physics_process(delta: float) -> void:
	#player = $"../Player"
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if alive:
		#if pushback == true:
			#push_back()
			#print("Pushback")
		if chase == true:
			attack_player()
			direction = (player.position - self.position).normalized()
			if direction.x > 0:
				$HurtBox.rotation_degrees = 0
				anim.flip_h = false
			else:
				$HurtBox.rotation_degrees = 180
				anim.flip_h = true
			velocity.x = direction.x * SPEED
		else:
			anim.play("idle")
			velocity.x = 0
		
		move_and_slide()
		hit_shake()
	else:
		pass
	
func attack_player():
	if attack == true and canAttack:
		anim.play("attack")
		$AttackSound.pitch_scale = randf_range(0.9, 1.1)
		$AttackSound.play()
		if playing_attacking_frames():
			if not damageDealt:
				if player.state == player.HEAL:
					game_manager.heal_interrupt( strength )
					pass
				else: 
					game_manager.damage( strength )
				damageDealt = true
			if anim.animation_finished:
				canAttack = false
				attack_cooldown.start()
		else:
			damageDealt = false
	else:
		anim.play("walk")

func playing_attacking_frames():
	return anim.frame == attack_frame

func take_damage():
	var player_damage = 1
	var damage_mult = 1
	if (attack):
		damage_mult = 1 + anim.frame_progress
	damage( player_damage * damage_mult )
	push_back()

func damage( damage_taken : float):
	health -= damage_taken
	update_damage(damage_taken)
	if health >= 0.1:
		update_label()
	else:
		health = 0
		update_label()
		anim.play("idle")
		
		alive = false
		set_collision_mask_value(1, false)
		set_collision_layer_value(2, false)
		death_sequence()

func hit_shake():
	if hit_timer:
		if hit_timer.is_stopped():
			pass
			$AnimatedSprite2D.position = Vector2.ZERO
		else:
			var shake = 5
			$AnimatedSprite2D.position.x = randf_range(shake, - shake)		

func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		chase = true

func _on_player_attack_range_body_entered(body: Node2D) -> void:
	#if not $AttackCooldown.is_stopped():
	#	pass
	if body.name == "Player":
		attack = true
		print("In Attack Range")

func _on_player_attack_range_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		attack = false
		print("Outside Attack Range")

func update_label():
	var health_scale : float = health/health_FULL
	$HealthBar.scale.x *= health_scale
	print("left:" + str (health_FULL - health) )

func _on_attack_cooldown_timeout() -> void:
	canAttack = true
	attack_cooldown.stop()

func update_damage ( damage : float):
	#print("Updating damage")
	var damage_taken_label: Label = $DamageTaken
	damage_taken_label.show()
	var value = snapped(damage, 0.01)
	damage_taken_label.text = "-"+str(value)
	$DamageTaken/DamageDisplayTimer.start()

func _on_damage_display_timer_timeout() -> void:
	$DamageTaken/DamageDisplayTimer.stop()
	$DamageTaken.hide()
	
func _on_hit_timer_timeout() -> void:
	hit_timer.stop()

func push_back():
	hit_timer.start()

func death_sequence():
	gate.queue_free()
	$DeathSound.play()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position - Vector2(0, 700), 3)
	#await get_tree().create_timer(3).timeout
	tween.tween_callback(queue_free)
