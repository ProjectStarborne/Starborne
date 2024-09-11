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

####### HEALTH #######
# Health Variables
@export var max_health = 100  # Maximum health for the player
var current_health = max_health  # Current health of the player
var health_bar  # Variable to store the health bar reference
var is_dead = false  # Player starts alive


func _ready() -> void:
	# Get the health bar node (adjust the path if necessary)
	health_bar = get_node("CanvasLayer/HealthBar")  
	health_bar.max_value = max_health
	health_bar.value = current_health
	print("ready was executed!")


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
	# Respawn after 2 seconds
	await get_tree().create_timer(2.0).timeout  # wait 2 sec before respawning
	respawn()

	
# TESTING METHOD FOR HEALTH
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"): 
		print("Enter key pressed!")
		take_damage(10)  #reduce health by 10 every time you press the enter key
	
	
func respawn() -> void:
	current_health = max_health  # Reset health
	update_health_bar()  # Update the health bar back to full
	is_dead = false  # Allow the player to move again
	global_position = Vector2(100, 100)  # Respawn at a specific position
	print("Respawning...")
