class_name Player extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: Node = $StateMachine
@onready var game_manager: Node = %GameManager

signal DirectionChanged( new_direction : Vector2 )
signal AttackFinished()

@onready var attack_timer: Timer = $AttackTimer
@onready var heal_timer: Timer = $HealTimer
@onready var dash_timer: Timer = $DashTimer
@onready var block_timer: Timer = $BlockTimer
@onready var hit_timer: Timer = $ImpactTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var direction : Vector2 = Vector2.ZERO
var facingDirection : int
const SPEED = 300.0
const DASH_VELOCITY = 900
const PUSHBACK_VELOCITY = 1800

var attack_strength : int = 1
var damage_taken = 0
var enemy_target : Enemy1
var target_in_range : bool = false
var damage_dealt = false

var state
const DEFAULT = 0
const ATTACK = 1
const DASH = 2
const HEAL = 3

var damage_taken_label_pos

func _ready() -> void:
	state_machine.initialize(self)
	state = DEFAULT
	facingDirection = 1
	$DamageTaken.hide()

func _process(delta: float) -> void:
	if state == DEFAULT:
		if Input.is_action_just_pressed("heal") and game_manager.can_heal():
			state = HEAL
			print("State is " + str(state))	
			heal()
		elif Input.is_action_just_pressed("attack"):
			state = ATTACK;
			$AttackSound.pitch_scale = randf_range(0.9, 1.1)
			$AttackSound.play()
			attack_timer.start()
			
		elif Input.is_action_just_pressed("dash") and $DashTimerCooldown.is_stopped():
			state = DASH
			$"Dash Sound".play()
			dash_timer.start()
			set_collision_layer_value(1, false)
			set_collision_mask_value(2, false)
			print("Dash")
	
	if state == ATTACK:
		if enemy_target and target_in_range:
			attack_enemy(enemy_target)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if state == DASH:
		if (direction.x != 0):
			velocity.x = DASH_VELOCITY * facingDirection
		else:
			velocity.x = DASH_VELOCITY * -facingDirection
		anim.play("dash")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	elif state == ATTACK:
		anim.play("attack")
		AttackFinished.emit()
		velocity.x = 0
		
	elif state == HEAL:
		velocity.x = 0
	
	else:
		direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		if direction:
			velocity.x = direction.x * SPEED
			facingDirection = direction.x
			DirectionChanged.emit ( facingDirection )
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
		if state == DEFAULT:
			if direction.x == 0:
				anim.play("idle")
			else: 
				anim.play("walk")
				anim.scale.x = direction.x
	move_and_slide()
	hit_shake()
	
func update_animation(state : String) -> void:
	anim.play(state)
	
func heal():
	$HealSound.play()
	print("Heal")
	anim.play("heal")
	game_manager.heal()

func hit_shake():
	if hit_timer.is_stopped():
		pass
		$AnimatedSprite2D.position = Vector2.ZERO
	else:
		var shake = 10
		$AnimatedSprite2D.position.x = randf_range(shake, - shake)


func _on_dash_timer_timeout() -> void:
	print("Dash End")
	state = DEFAULT
	set_collision_layer_value(1, true)
	set_collision_mask_value(2, true)
	dash_timer.stop()
	$DashTimerCooldown.start()

func _on_hit_timer_timeout() -> void:
	hit_timer.stop()
	
func is_facing_enemy( x : int) -> bool:
	var distance = position.x - x
	var calculation = distance / facingDirection
	return calculation < 0
	
func update_damage ( damage : int):
	print("Updating damage")
	var damage_taken_label: Label = $DamageTaken
	damage_taken_label.show()
	damage_taken_label.text = "-"+str(damage)
	damage_taken_label_pos = damage_taken_label.position
	$DamageTaken/DamageDisplayTimer.start()

func _on_damage_display_timer_timeout() -> void:
	$DamageTaken/DamageDisplayTimer.stop()
	$DamageTaken.hide()
	
func has_attacked() -> bool:
	return state == ATTACK and anim.frame == 1

func _on_animated_sprite_2d_animation_finished() -> void:
	if state == ATTACK:
		print("Attack End")
		state = DEFAULT
	elif state == HEAL:
		print("Heal End")
		state = DEFAULT

func _on_dash_timer_cooldown_timeout() -> void:
	$DashTimerCooldown.stop()


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if (body is Enemy1):
		#print("Enemy found")
		enemy_target = body
		target_in_range = true
			
func attack_enemy( enemy : Enemy1):
	if anim.frame == 2:
		if not damage_dealt:
			enemy.take_damage()
			damage_dealt = true
	else: 
		damage_dealt = false


func _on_hurt_box_body_exited(body: Node2D) -> void:
	if (body is Enemy1):
		target_in_range = false

func push_back():
	hit_timer.start()
	#velocity.x = DASH_VELOCITY * -facingDirection
