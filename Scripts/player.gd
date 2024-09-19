extends CharacterBody2D


const SPEED = 200.0
@export var friction = 500

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO
	
	if is_dead:
		return  # Prevent movement if dead
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_pressed("up"):
		direction.y -= 1
		$Sprite2D/AnimationPlayer.play("walk_up")
	if Input.is_action_pressed("down"):
		direction.y += 1
		$Sprite2D/AnimationPlayer.play("walk_down")
	if Input.is_action_pressed("left"):
		direction.x -= 1
		
		if direction.y == 0:
			$Sprite2D/AnimationPlayer.play("walk_left")
	if Input.is_action_pressed("right"):
		direction.x += 1
		
		if direction.y == 0:
			$Sprite2D/AnimationPlayer.play("walk_right")
	
	direction = direction.normalized()
	velocity = direction * SPEED
	
	if direction == Vector2.ZERO:
		$Sprite2D/AnimationPlayer.stop()
	
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
	update_health_color()
	update_oxygen_color()
	

func take_damage(damage: int) -> void:
	current_health -= damage
	if current_health <= 0:
		current_health = 0
		game_over()  #calls a game over function when health reaches 0
		print("Current Health:", current_health)  
	update_health_bar()  #update the health bar whenever health changes
	update_health_color()  # Update color after taking damage


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
	update_health_color()
	current_oxygen = max_oxygen  # reset oxygen level
	update_oxygen_bar()
	update_oxygen_color()
	is_dead = false  # allow the player to move again
	global_position = Vector2(100, 100)  #respawn at  100 100 
	print("Respawning...")


func update_health_color() -> void:
	var health_percentage = float(current_health) / float(max_health)  # Health as a percentage (0 to 1)

	var fill_stylebox = health_bar.get("theme_override_styles/fill")
	if fill_stylebox == null:
		# If there's no existing style, create one
		fill_stylebox = StyleBoxFlat.new()
		health_bar.set("theme_override_styles/fill", fill_stylebox)

	# Set the color based on health percentage thresholds
	if health_percentage > 0.75:
		fill_stylebox.bg_color = Color(0.0, 0.7, 0.0)  # Green for health > 75%
	elif health_percentage > 0.5:
		fill_stylebox.bg_color = Color(1.0, 1.0, 0.0)  # Yellow for health between 50% and 75%
	elif health_percentage > 0.25:
		fill_stylebox.bg_color = Color(1.0, 0.65, 0.0)  # Orange for health between 25% and 50%
	else:
		fill_stylebox.bg_color = Color(1.0, 0.0, 0.0)  # Red for health below 25%










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
	
	
# function to deplete oxygen over time
func deplete_oxygen(delta: float) -> void:
	var oxygenDrainRate = 2 * delta # change these two variables to control the drainage rate
	var healthDrainRate = 15
	
	if current_oxygen > 0:
		current_oxygen -= oxygenDrainRate 
		if current_oxygen <= 0:
			current_oxygen = 0
			oxygen_depleting = true  # start damaging health once oxygen is depleted
	else:
		# if oxygen is depleted, start affecting health
		if oxygen_depleting:
			time_since_last_health_chip += delta
			if time_since_last_health_chip >= health_chip_delay:
				take_damage(healthDrainRate)  # chip away at health at 15 per sec
				time_since_last_health_chip = 0.0  # reset timer after health damage
	update_oxygen_bar()
	update_oxygen_color()
	


func update_oxygen_color() -> void:
	var oxygen_percentage = float(current_oxygen) / float(max_oxygen)  # Oxygen as a percentage (0 to 1)

	var fill_stylebox = oxygen_bar.get("theme_override_styles/fill")
	if fill_stylebox == null:
		# If there's no existing style, create one
		fill_stylebox = StyleBoxFlat.new()
		oxygen_bar.set("theme_override_styles/fill", fill_stylebox)

	# Set the color based on oxygen percentage thresholds
	if oxygen_percentage > 0.75:
		fill_stylebox.bg_color = Color(0.0, 0.5, 1.0)  # Blue for oxygen > 75%
	elif oxygen_percentage > 0.5:
		fill_stylebox.bg_color = Color(0.0, 1.0, 1.0)  # Cyan for oxygen between 50% and 75%
	elif oxygen_percentage > 0.25:
		fill_stylebox.bg_color = Color(1.0, 1.0, 0.0)  # Yellow for oxygen between 25% and 50%
	else:
		fill_stylebox.bg_color = Color(1.0, 0.0, 0.0)  # Red for oxygen below 25%
