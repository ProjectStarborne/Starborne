extends CharacterBody2D

class_name Player

# Constants
const SPEED = 300.0 # Normal speed of the player
const NORMAL_FRICTION = 1500.0 
const ICE_FRICTION = 100.0  # Low friction for sliding on ice
#const LAVA_FRICTION = 100.0  # Low friction for sliding on ice

# Exported variable for friction, which controls how quickly the player slows down after moving
@export var friction = NORMAL_FRICTION
# Vector to hold the player's knockback velocity (force applied when hit)
var knockback_velocity = Vector2.ZERO
# Timer to track how long the knockback effect lasts
var knockback_timer = 0.0
# Constant defining the duration of the knockback effect (0.5 seconds in this case)
const KNOCKBACK_DURATION = 0.5

#Oxygen leak system variables
var oxygen_leaking = false  # Track if oxygen is leaking
var oxygen_leak_rate_multiplier = 2.0  # Rate multiplier for faster oxygen depletion
var warning_timer = 0.0  # Timer to control warning text flickers
var warning_visible = false  # To track if warning text is currently visible
@onready var warning_label = get_node("/root/Environment/CanvasLayer/OxygenLeakWarning")  # Reference to warning label in UI
@onready var warning_audio = get_node("/root/Environment/CanvasLayer/OxygenLeakWarning/Oxygen_Warning")  # Warning sound player

@onready var flashlight: PointLight2D = $Flashlight
signal picked_up_item(item : Item, fail : bool)

# Inventory
var inventory : Inventory = Inventory.new()

# Upgrade Level
var upgrade_level = 0

# World Variable
@onready var world = get_parent()

func _physics_process(delta: float) -> void:
	# Initialize a direction vector to store player input
	var direction = Vector2.ZERO

	# Check if the player is standing on ice, and adjust friction accordingly
	ice_check()
	# Check if the player is standing on lava, and slow player down and take damage if so
	lava_check()

	# Check if the player is dead, and prevent movement if so
	if is_dead:
		return  # Early exit to stop further processing

	# Check if the player is currently in the knockback state
	if knockback_timer > 0:
		# Apply the knockback force by setting the player's velocity to knockback_velocity
		velocity = knockback_velocity
		# Reduce the knockback timer as time progresses
		knockback_timer -= delta
	else:
		# Reset knockback velocity when knockback is finished
		knockback_velocity = Vector2.ZERO

		# Get the player input for movement
		if Input.is_action_pressed("up"):
			direction.y -= 1  # Move up
			$Sprite2D/AnimationPlayer.play("walk_up")
		if Input.is_action_pressed("down"):
			direction.y += 1  # Move down
			$Sprite2D/AnimationPlayer.play("walk_down")
		if Input.is_action_pressed("left"):
			direction.x -= 1  # Move left
			if direction.y == 0:
				$Sprite2D/AnimationPlayer.play("walk_left")
		if Input.is_action_pressed("right"):
			direction.x += 1  # Move right
			if direction.y == 0:
				$Sprite2D/AnimationPlayer.play("walk_right")

		# Normalize the direction vector for consistent movement speed
		direction = direction.normalized()

		# Update velocity based on direction and apply friction when there's no input
		if direction != Vector2.ZERO:
			velocity = direction * current_speed
		else:
			# Apply friction to slow down when there's no input
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# Handle flashlight aiming at the mouse position
	flashlight.look_at(get_global_mouse_position())
	
	# Dynamic Footstep Caller
	footstep_handler()

	# Stop animations if there's no movement
	if direction == Vector2.ZERO:
		$Sprite2D/AnimationPlayer.stop()

	# Flicker warning text if oxygen is leaking
	if oxygen_leaking:
		handle_warning(delta)

	# Move the player based on the current velocity
	move_and_slide()

	# Deplete oxygen over time
	deplete_oxygen(delta)

####### KNOCKBACK #######
# Function to apply knockback to the player
func apply_knockback(force: Vector2) -> void:
	# Set the knockback velocity to the given force (direction and strength of the knockback)
	knockback_velocity = force

	# Start the knockback timer, which lasts for the duration defined in KNOCKBACK_DURATION
	knockback_timer = KNOCKBACK_DURATION

####### ICE SLIDING ######

@onready var tile_map = get_node("/root/Environment/TileMap")  # Reference to your TileMap node

# Method to check if the tile under the player is ice
func ice_check():
	var player_pos : Vector2 = global_position  # player's global position
	var local_player_pos : Vector2 = tile_map.to_local(player_pos)  # convert to local position relative to TileMap
	var tile_pos : Vector2i = tile_map.local_to_map(local_player_pos)  # convert local position to TileMap grid position
	var tile_data : TileData = tile_map.get_cell_tile_data(0, tile_pos)

	if tile_data:
		var tile_id = tile_data.get_custom_data_by_layer_id(TileDetector.TERRAIN_ID_LAYER)
		if tile_id == TileDetector.TerrainType.ICE:
			#print("This tile is ice!")
			friction = ICE_FRICTION  # Set friction to ice friction
		else:
			#print("This tile is not ice.")
			friction = NORMAL_FRICTION  # Default friction when not on ice
	else:
		#print("No tile data")
		friction = NORMAL_FRICTION  # Default friction when no tile data


####### LAVA SYSTEM ######

# Reference to the fire effect AnimatedSprite2D
@onready var fire_sprite = $Fire
@onready var fire_light = $Fire/PointLight2D 

var is_lava_custom_data = "is_lava"
var LAVA_SPEED_FACTOR = 0.5  # Factor to slow down the player on lava (50% slower)
var LAVA_DAMAGE = 10  # Amount of damage to apply while on lava
var damage_interval = 1.0  # Time in seconds between each damage tick
var last_damage_time = 0.0  # Keeps track of the last time damage was applied
# Color for the firelight effect (warm orange)
var fire_color = Color(1.0, 0.5, 0.1)  # RGB values for orange

# Variable to hold the current speed, initially set to normal speed
var current_speed = SPEED  # Initialize with the constant SPEED value

# Method to check if the tile under the player is lava
# Reference to the fire animation and light nodes


func lava_check():
	var player_pos : Vector2 = global_position  # Player's global position
	var local_player_pos : Vector2 = tile_map.to_local(player_pos)  # Convert to local position relative to TileMap
	var tile_pos : Vector2i = tile_map.local_to_map(local_player_pos)  # Convert local position to TileMap grid position
	var tile_data : TileData = tile_map.get_cell_tile_data(0, tile_pos)

	if tile_data:
		var tile_id = tile_data.get_custom_data_by_layer_id(TileDetector.TERRAIN_ID_LAYER)
		if tile_id == TileDetector.TerrainType.LAVA:
			# Slow down the player's speed by reducing the current_speed
			current_speed = SPEED * LAVA_SPEED_FACTOR  # Adjust the player's current speed when on lava

			# Check if enough time has passed since last damage
			if Time.get_ticks_msec() / 1000.0 - last_damage_time >= damage_interval:
				take_damage(LAVA_DAMAGE)  # Apply damage to the player
				last_damage_time = Time.get_ticks_msec() / 1000.0  # Update last damage time

			# Play fire animation
			if fire_sprite.animation != "on_fire":
				fire_sprite.animation = "on_fire"  # Set the animation to "on_fire"
			fire_sprite.play("on_fire")  # Start the fire animation if not already playing
			fire_sprite.visible = true  # Make sure the fire animation is visible

			# Enable the light and set properties
			fire_light.visible = true
			fire_light.color = fire_color  # Set the light to a warm orange color
			fire_light.energy = 0.8  # Adjust energy level as needed
		else:
			# Reset speed and stop fire animation when not on lava
			current_speed = SPEED
			fire_sprite.stop()  # Stop the fire animation
			fire_sprite.visible = false  # Hide the fire animation when not on lava

			# Disable the light
			fire_light.visible = false
			fire_light.energy = 0.0  # Reset energy when not on lava
	else:
		current_speed = SPEED  # Reset speed when no tile data found
		fire_sprite.stop()  # Stop the fire animation
		fire_sprite.visible = false  # Hide the fire animation
		fire_light.visible = false  # Disable the light
		fire_light.energy = 0.0  # Reset energy when not on lava

####### OXYGEN LEAK SYSTEM ######

# Start oxygen leak
func start_oxygen_leak() -> void:
	oxygen_leaking = true
	# Center the warning label on the screen
	#center_warning_label()
	# Display and start flickering the warning label
	warning_label.text = "WARNING! Oxygen leak detected!"
	warning_visible = true
	warning_label.visible = true
	warning_audio.stream.loop = true
	warning_audio.play()  # Play the warning sounds


# Handle flickering of warning text
func handle_warning(delta: float) -> void:
	warning_timer += delta
	if warning_timer >= 0.5:  # Flicker every 0.5 seconds
		warning_visible = not warning_visible  # Toggle visibility
		warning_label.visible = warning_visible
		warning_timer = 0.0


# function to fix the oxygen leak (using duct tape or if you die and respawn)
func fix_oxygen_leak() -> void:
	oxygen_leaking = false
	warning_label.visible = false  # Hide the warning text

	# Stop the warning sound and disable looping
	warning_audio.stop()
	warning_audio.stream.loop = false




####### HEALTH SYSTEM #######

# Health Variables
@onready var health_bar = get_node("/root/Environment/CanvasLayer/HealthBar")  # Reference to the health bar node in the scene
@export var max_health = 100  # Maximum health for the player (adjustable)
var current_health = max_health  # Player's current health, initialized to the maximum
var is_dead = false  # Boolean to track if the player is dead (starts alive)


# Called when the node is added to the scene
func _ready() -> void: 
	# Set the health bar's maximum and current values to reflect the player's health
	health_bar.max_value = max_health
	health_bar.value = current_health

	# Set up the oxygen bar (assuming it is defined elsewhere)
	oxygen_bar.max_value = max_oxygen
	oxygen_bar.value = current_oxygen

	# Update the health and oxygen bar colors to reflect current values
	update_health_color()
	update_oxygen_color()


# Function to handle when the player takes damage
func take_damage(damage: int) -> void:
	# Reduce the player's current health by the damage amount
	current_health -= damage
	
	# If health drops to 0 or below, trigger game over
	if current_health <= 0:
		current_health = 0  # Prevent health from going negative
		game_over()  # Call the game over function
		print("Current Health:", current_health)  # Output current health for debugging
	
	# Update the health bar and color after taking damage
	update_health_bar()
	update_health_color()


# Function to update the health bar UI to reflect the current health
func update_health_bar() -> void:
	health_bar.value = current_health
# Function to handle the game over state when the player's health reaches 0
func game_over() -> void:
	print("Game Over!")  # Output "Game Over" for debugging purposes
	
	# Play the game over sound (rn its "lego_death.wav" sound effect lmao)
	var audio_player = get_node("Death_Sound")
	if audio_player:
		print("Audio player found!")  # Debugging statement
		#audio_player.play()  # Play the sound
	
	is_dead = true  # Set the player to dead, disabling further movement
	# Wait 2 seconds before respawning the player
	await get_tree().create_timer(2.0).timeout
	respawn()  # Call the respawn function after the timer
	print("Oxygen leaking state after respawn: ", oxygen_leaking)



# Function to handle respawning the player
func respawn() -> void:
	#Deactivate oxygen leak, if present upon death
	fix_oxygen_leak()
	#Bug fix workaround. The same rock cannot trigger oxygen drain twice cause its fuked
	get_tree().reload_current_scene()
	
	# Reset the player's health, oxygen, and other stats upon respawn
	current_health = max_health  # Reset health to full
	update_health_bar()  # Update the health bar UI
	update_health_color()  # Update the health bar color to green
	
	# Reset the player's oxygen levels 
	current_oxygen = max_oxygen  
	update_oxygen_bar()  # Update the oxygen bar UI
	update_oxygen_color()  # Update the oxygen bar color to blue
	
	is_dead = false  # Allow the player to move again (remove the dead state)
	
	# Respawn the player at a predefined position (100, 100)
	global_position = Vector2(100, 100)
	print("Respawning...")  


# Function to update the health bar's color based on the player's current health percentage
func update_health_color() -> void:
	# Calculate the player's health as a percentage (between 0 and 1)
	var health_percentage = float(current_health) / float(max_health)
	
	# Get the fill stylebox of the health bar to change its background color
	var fill_stylebox = health_bar.get("theme_override_styles/fill")
	if fill_stylebox == null:
		# If there's no existing style, create a new one
		fill_stylebox = StyleBoxFlat.new()
		health_bar.set("theme_override_styles/fill", fill_stylebox)

	# Set the color of the health bar based on the health percentage:
	if health_percentage > 0.75:
		fill_stylebox.bg_color = Color(0.0, 0.7, 0.0)  # Green for health > 75%
	elif health_percentage > 0.5:
		fill_stylebox.bg_color = Color(1.0, 1.0, 0.0)  # Yellow for health between 50% and 75%
	elif health_percentage > 0.25:
		fill_stylebox.bg_color = Color(1.0, 0.65, 0.0)  # Orange for health between 25% and 50%
	else:
		fill_stylebox.bg_color = Color(1.0, 0.0, 0.0)  # Red for health below 25%



####### OXYGEN SYSTEM #######

# Oxygen Variables
@onready var oxygen_bar = get_node("/root/Environment/CanvasLayer/OxygenBar")  # Reference to the oxygen bar node in the UI
@export var max_oxygen = 100  # Maximum oxygen level for the player
var current_oxygen = max_oxygen  # Player's current oxygen level, initialized to max
var oxygen_gone = false  # Boolean to track whether oxygen depletion has started. cant remember if we used this or not 


# Variables for managing health reduction once oxygen is depleted
var health_chip_delay = 1.0  # Delay in seconds between health reductions (when oxygen is depleted)
var time_since_last_health_chip = 0.0  # Tracks time since the last health reduction


# Function to update the oxygen bar UI when the oxygen level changes
func update_oxygen_bar() -> void:
	oxygen_bar.value = current_oxygen  # Set the oxygen bar's value to the current oxygen level


# Function to deplete oxygen over time (called every frame)
func deplete_oxygen(delta: float) -> void:
	var oxygenDrainRate = 2 * delta  # Controls how quickly oxygen drains over time (adjustable)
	var healthDrainRate = 15  # Amount of health to reduce per "tick" when oxygen is depleted
	
	if oxygen_leaking:
		oxygenDrainRate *= oxygen_leak_rate_multiplier  # Increase drain rate if leaking
	
	# If the player still has oxygen, continue to deplete it
	if current_oxygen > 0:
		current_oxygen -= oxygenDrainRate  # Decrease oxygen based on the drain rate
		
		# If oxygen drops to 0 or below, trigger the start of health damage
		if current_oxygen <= 0:
			current_oxygen = 0  # Ensure oxygen does not go below 0
			oxygen_gone = true  # Enable health depletion now that oxygen is gone
	else:
		# Once oxygen is depleted, start affecting health
		if oxygen_gone:
			# Track time since the last health chip and reduce health periodically
			time_since_last_health_chip += delta
			if time_since_last_health_chip >= health_chip_delay:
				take_damage(healthDrainRate)  # Reduce player's health by a fixed amount (15)
				time_since_last_health_chip = 0.0  # Reset the timer after each health reduction
	
	# Update the oxygen bar and its color to reflect the current oxygen level
	update_oxygen_bar()
	update_oxygen_color()


# Function to update the oxygen bar's color based on the player's current oxygen level
func update_oxygen_color() -> void:
	# Calculate the oxygen as a percentage (between 0 and 1)
	var oxygen_percentage = float(current_oxygen) / float(max_oxygen)

	# Get the fill stylebox of the oxygen bar to modify its color
	var fill_stylebox = oxygen_bar.get("theme_override_styles/fill")
	if fill_stylebox == null:
		# If there's no existing style, create a new one
		fill_stylebox = StyleBoxFlat.new()
		oxygen_bar.set("theme_override_styles/fill", fill_stylebox)

	# Set the color of the oxygen bar based on the oxygen percentage:
	if oxygen_percentage > 0.75:
		fill_stylebox.bg_color = Color(0.0, 0.5, 1.0)  # Blue for oxygen > 75%
	elif oxygen_percentage > 0.5:
		fill_stylebox.bg_color = Color(0.0, 1.0, 1.0)  # Cyan for oxygen between 50% and 75%
	elif oxygen_percentage > 0.25:
		fill_stylebox.bg_color = Color(1.0, 1.0, 0.0)  # Yellow for oxygen between 25% and 50%
	else:
		fill_stylebox.bg_color = Color(1.0, 0.0, 0.0)  # Red for oxygen below 25% 
		


####### Resource Management System #######

func on_item_picked_up(item:Item) -> void:
	# Check first to see if the inventory is full
	# If inventory is full, do not pickup item and emit failure
	# Otherwise pickup item and emit success
	
	if !inventory.add_item(item):
		print("Inventory Full!")
		picked_up_item.emit(item, false)
	else:
		print("I got ", item.name)
		picked_up_item.emit(item, true)
		
		
####### Dynamic Footsteps #######
func footstep_handler() -> void:
	# Grabbing player's local tile information
	var local_pos = tile_map.to_local(global_position)
	var tile_pos = tile_map.local_to_map(local_pos)
	var tile_data : TileData = tile_map.get_cell_tile_data(0, tile_pos)
	
	# If tile data doesn't exist or not moving, do nothing
	if (!tile_data or velocity == Vector2.ZERO):
		return
	
	var tile_id = tile_data.get_custom_data_by_layer_id(TileDetector.TERRAIN_ID_LAYER)
	var footstep_player : AudioStreamPlayer2D = $Footsteps
	var audio_timer : Timer = $Footsteps/Timer
	
	match tile_id:
		TileDetector.TerrainType.ROCK:
			pass # set different audio here
			
	if audio_timer.time_left <= 0:
		footstep_player.pitch_scale = randf_range(0.8, 1.0)
		footstep_player.play()
		audio_timer.start(0.3)
