extends CharacterBody2D

const SPEED = 300.0
@export var friction = 500

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO
	
	if is_dead:
		return  # Prevent movement if dead
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_pressed("up"):
		direction.y -= 1
	elif Input.is_action_pressed("down"):
		direction.y += 1
	elif Input.is_action_pressed("left"):
		direction.x -= 1
	elif Input.is_action_pressed("right"):
		direction.x += 1
	
	direction = direction.normalized()
	velocity = direction * SPEED

		
	#print("x: ", velocity.x, " y: ", velocity.y)
	move_and_slide()
	deplete_oxygen(delta)


####### HEALTH #######
# Health Variables
@onready var health_bar = get_node("/root/Environment/CanvasLayer/HealthBar")
@export var max_health = 100  # Maximum health for the player
var current_health = max_health  # Current health of the player
var is_dead = false  # Player starts alive


func _ready() -> void: 
	health_bar.max_value = max_health
	health_bar.value = current_health
	oxygen_bar.max_value = max_oxygen
	oxygen_bar.value = current_oxygen


func take_damage(damage: int) -> void:
	current_health -= damage
	if current_health <= 0:
		current_health = 0
		game_over()  #calls a game over function when health reaches 0
		print("Current Health:", current_health)  
	update_health_bar()  #update the health bar whenever health changes


func update_health_bar() -> void:
	health_bar.value = current_health


func game_over() -> void:
	print("Game Over!")
	is_dead = true
	# respawn after 2 seconds
	await get_tree().create_timer(2.0).timeout  # wait 2 sec before respawning
	respawn()

	
# TESTING METHOD FOR HEALTH
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"): 
		take_damage(10)  #reduce health by 10 every time you press the enter key
	
	
func respawn() -> void:
	current_health = max_health  # reset the health
	update_health_bar()  # update the health bar back to full
	current_oxygen = max_oxygen  # reset oxygen level
	update_oxygen_bar()
	is_dead = false  # allow the player to move again
	global_position = Vector2(100, 100)  #respawn at  100 100 
	print("Respawning...")


####### OXYGEN #######

# Oxygen Variables
@onready var oxygen_bar  = get_node("/root/Environment/CanvasLayer/OxygenBar")
@export var max_oxygen = 100  # Maximum oxygen level
var current_oxygen = max_oxygen  # Current oxygen level
var oxygen_depleting = false  # Track whether oxygen is being depleted
# Function to deplete oxygen over time
var health_chip_delay = 1.0  # Delay in seconds between health reductions
var time_since_last_health_chip = 0.0  # Tracks time since last health reduction


func update_oxygen_bar() -> void:
	oxygen_bar.value = current_oxygen
	
	
# Function to deplete oxygen over time
func deplete_oxygen(delta: float) -> void:
	if current_oxygen > 0:
		current_oxygen -= (5 / 2) * delta  # Oxygen depletes twice as slow
		if current_oxygen <= 0:
			current_oxygen = 0
			oxygen_depleting = true  # Start damaging health once oxygen is depleted
	else:
		# If oxygen is depleted, start affecting health
		if oxygen_depleting:
			time_since_last_health_chip += delta
			if time_since_last_health_chip >= health_chip_delay:
				take_damage(15)  # Chip away at health
				time_since_last_health_chip = 0.0  # Reset timer after health damage
	update_oxygen_bar()
