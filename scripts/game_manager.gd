extends Node

@onready var hp: Label = $"../UI2/Health"
@onready var sp: Label = $"../UI2/Scraps"
@onready var player: CharacterBody2D = $"../Player"
@onready var hit_timer: Timer = $HitTimer
@onready var gate_5: StaticBody2D = $"../Area5/Gate5"

# States

const RUNNING = 0
const LOST = 1
const WIN = 2

# Game Over Messages
var Lost = "Game Over!
Try Again"
var Win = "CONGRATULATIONS!
YOU HAVE TAKEN BACK THE THRONE!"

var gameState = RUNNING

var health = 0
var scraps = 0

const health_MAX = 10

var previous_health

var bgmPlaying = false

func _ready() -> void:
	health = health_MAX
	scraps = 0
	
	if gate_5:
		gate_5.visible = false
		gate_5.set_collision_layer_value(1, false)
		gate_5.set_collision_mask_value(1, false)
	
	start_bgm()
	
func start_bgm():
	var bgm = $"../BGM"
	if bgm:
		bgm.play()

func addScrap():
	scraps += 1
	updateScrapLabel()

func heal():
	previous_health = health
	health = health_MAX
	scraps -= 1
	updateLabels()
	print("heal")
		
func can_heal():
	return scraps > 0 and health < health_MAX

func damage( attack_damage : int ):
	print("Damage: " + str(attack_damage))		
	
	health -= attack_damage
	updateHealthLabel()
	player.push_back()
	player.update_damage( attack_damage )
	
	if (health <= 0):
		set_state_lost()
		pass
		
func heal_interrupt( attack_damage : int):
	print ("Heal Interrupted!")
	health = previous_health
	damage( 2 * attack_damage )
	player.state = player.DEFAULT
	
func updateHealthLabel():
	hp.text = "Health: " + str(health) + " / " + str(health_MAX)
	
func updateScrapLabel():
	sp.text = "Scraps: " + str(scraps)
	
func updateLabels():
	updateHealthLabel()
	updateScrapLabel()

func set_state_win():
	gameState = WIN
	print("WIN")
	$"../BGM".stop()
	get_tree().change_scene_to_file("res://scenes/menu_game_won.tscn")
#	$"../GameWon".play()
	$"../UI2/GameOverMessage".text = Win

func set_state_lost():
	gameState = LOST
	print("LOSE")
	$"../BGM".stop()
	Engine.time_scale = 0.5
	player.rotate(90)
	
	await get_tree().create_timer(1).timeout
	
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://scenes/menu_game_over.tscn")
#	$"../GameLost".play()
	$"../UI2/GameOverMessage".text = Lost


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		gate_5.visible = true
		gate_5.set_collision_layer_value(1, true)
		gate_5.set_collision_mask_value(1, true)
