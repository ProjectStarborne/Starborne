extends CharacterBody2D

class_name Player

# Scene check variable
var in_level : bool
# Scene check variable
var in_ship : bool

#Keeps track of last facing direction for animation purposes
var last_facing_direction = Vector2.DOWN

const SPEED = 300.0 # Normal speed of the player

enum Frictions {
	ICE = 200,
	NORM = 5000
}

# Tracks player's status on terrain
var stepping_tile: int
var friction = Frictions.NORM 

# Determines if oxygen will be depleted
@export var oxygen_handler: bool = true

signal damage_taken
signal oxygen_changed

@onready var camera : Camera2D = $AnchorCamera2D

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
@onready var warning_label = $"../CanvasLayer/OxygenLeakWarning"  # Reference to warning label in UI
@onready var warning_audio = $"../CanvasLayer/OxygenLeakWarning/Oxygen_Warning" # Warning sound player
@onready var leak_audio = $"../CanvasLayer/OxygenLeakWarning/Oxygen_Leak" # leak sound 

# Reference to the fire effect AnimatedSprite2D
@onready var fire_sprite = $Fire
@onready var fire_light = $Fire/PointLight2D 

var LAVA_SPEED_FACTOR = 0.5  # Factor to slow down the player on lava (50% slower)
var LAVA_DAMAGE = 10  # Amount of damage to apply while on lava
var damage_interval = 1.0  # Time in seconds between each damage tick
var last_damage_time = 0.0  # Keeps track of the last time damage was applied

# Variable to hold the current speed, initially set to normal speed
var current_speed = SPEED  # Initialize with the constant SPEED value

# Oxygen Variables
@export var max_oxygen = 100  # Maximum oxygen level for the player
var current_oxygen = max_oxygen  # Player's current oxygen level, initialized to max
var oxygen_gone = false  # Boolean to track whether oxygen depletion has started. cant remember if we used this or not 

# Variables for managing health reduction once oxygen is depleted
var health_chip_delay = 1.0  # Delay in seconds between health reductions (when oxygen is depleted)
var time_since_last_health_chip = 0.0  # Tracks time since the last health reduction

# Health Variables
@export var max_health = 100.0  # Maximum health for the player (adjustable)
var current_health = max_health  # Player's current health, initialized to the maximum
var is_dead = false  # Boolean to track if the player is dead (starts alive)

@onready var flashlight: PointLight2D = $Flashlight

signal picked_up_item(item : Item, msg : String)

# Inventory
var inventory : Inventory

# Hotbar
@onready var hotbar = %HotBar

# Inventory UI
@onready var inventory_ui: Control = $"../CanvasLayer/InventoryUI"
@onready var shop_ui: Control = $"../CanvasLayer/ShopUI"
@onready var ship_upgrades: Control = $"../CanvasLayer/ShipUpgrades"
@onready var navigation: Control = $"../CanvasLayer/Navigation"
@onready var ship_storage_ui: Control = $"../CanvasLayer/ShipStorageUI"

var drilling = false
var target_rock = null

# World Variable
@onready var world = get_parent()

var allowed_to_move = true

# Called when the node is added to the scene
func _ready() -> void: 
	in_level = get_tree().current_scene.name == "Environment"
	in_ship = get_tree().current_scene.name == "Shipinterior"  # Add condition for ShipInterior scene
	
	inventory = Globals.inventory
	# Wait for Hotbar to be ready before updating
	await hotbar.ready
	hotbar.update_hotbar_ui(inventory)
	
	# Load the player's health and oxygen from the global variables
	current_health = Globals.current_health
	current_oxygen = Globals.current_oxygen
	
	# Signal to update the health and oxygen bar colors to reflect current values
	damage_taken.emit()
	oxygen_changed.emit()
	
	# Check if the oxygen is leaking when entering the world scene
	if Globals.oxygen_leaking:
		start_oxygen_leak()
	else:
		fix_oxygen_leak()
	
	# Only connect to the game over screen if not in the ShipInterior scene
	if in_level and game_over_screen != null:
		# Connect the respawn signal from the GameOver screen to the player
		game_over_screen.connect("respawn_signal", Callable(self, "_on_respawn_signal"))
	
	if !in_level:
		current_speed = SPEED / 4
		
	Dialogic.signal_event.connect(stop_movement)
	
	warning_audio.volume_db = -25  # Adjust volume in decibels (lower is quieter)
	leak_audio.volume_db = -35  # Adjust volume in decibels


func _physics_process(delta: float) -> void:
	
	if $Sprite2D/AnimationPlayer.current_animation == "health":
		return
	if $Sprite2D/AnimationPlayer.current_animation == "oxygen":
		return
	if $Sprite2D/AnimationPlayer.current_animation == "duct_tape":
		return
	if $Sprite2D/AnimationPlayer.current_animation == "health":
		return
	if $Sprite2D/AnimationPlayer.current_animation == "drill_up":
		return
	if $Sprite2D/AnimationPlayer.current_animation == "drill_down":
		return
	if $Sprite2D/AnimationPlayer.current_animation == "drill_right":
		return
	if $Sprite2D/AnimationPlayer.current_animation == "drill_left":
		return
		
	# Initialize a direction vector to store player input
	var direction = Vector2.ZERO
	
	# Handle movement when player is busy
	if allowed_to_move:
		direction = Input.get_vector("left", "right", "up", "down")
		
	# Should only work in Environment root node
	# Handle flashlight aiming at the mouse position
	handle_flashlight()
		
	# Dynamic Footstep Caller
	footstep_handler()
		
	# Flicker warning text if oxygen is leaking
	if oxygen_leaking:
		handle_warning(delta)
	
	# Check if inside the ship to refill oxygen or deplete outside
	var is_in_ship = get_tree().current_scene.name == "Shipinterior"
	
	if is_in_ship and current_oxygen < max_oxygen:
		# Refill oxygen while in the ship
		refill_oxygen(delta)
	elif oxygen_handler:
		# Deplete oxygen over time when not in the ship
		deplete_oxygen(delta)
	
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
	
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * current_speed, friction * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Handle input for using items
	if Input.is_action_just_pressed("action") and not inventory_ui.visible and not shop_ui.visible and not navigation.visible and not ship_upgrades.visible and not ship_storage_ui.visible:
		var item_index = hotbar.get_selected_slot()
		var hotbar_list = inventory.get_hotbar_items()
			
		use_item(hotbar_list[item_index], item_index)
		
			
	if Input.is_action_just_released("action") and not inventory_ui.visible:
		# Disable drilling
		drilling = false
			 
	# Stop animations if there's no movement
	if direction == Vector2.ZERO:
		if $Sprite2D/AnimationPlayer.current_animation == "walk_right":
			$Sprite2D/AnimationPlayer.stop()
		if $Sprite2D/AnimationPlayer.current_animation == "walk_left":
			$Sprite2D/AnimationPlayer.stop()
		if $Sprite2D/AnimationPlayer.current_animation == "walk_up":
			$Sprite2D/AnimationPlayer.stop()
		if $Sprite2D/AnimationPlayer.current_animation == "walk_down":
			$Sprite2D/AnimationPlayer.stop()
			
	handle_special_movement()
	handle_animation()
	move_and_slide()


func handle_animation():
	# Direction -> Animation
	
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO:
		last_facing_direction = direction
		
		
	if Input.is_action_pressed("up"):
		$Sprite2D/AnimationPlayer.play("walk_up")
	elif Input.is_action_pressed("down"):
		$Sprite2D/AnimationPlayer.play("walk_down")
	elif Input.is_action_pressed("left"):
		$Sprite2D/AnimationPlayer.play("walk_left")
	elif Input.is_action_pressed("right"):
		$Sprite2D/AnimationPlayer.play("walk_right")


func handle_special_movement(): 
	match stepping_tile:
		TileDetector.TerrainType.ICE:
			friction = Frictions.ICE
		TileDetector.TerrainType.LAVA:
			apply_lava()
		_:
			friction = Frictions.NORM
			remove_lava()


func handle_flashlight():
	if !flashlight: return
	flashlight.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("toggle_flashlight"):
		flashlight.visible = !flashlight.visible

####### KNOCKBACK #######
# Function to apply knockback to the player
func apply_knockback(force: Vector2) -> void:
	# Set the knockback velocity to the given force (direction and strength of the knockback)
	knockback_velocity = force

	# Start the knockback timer, which lasts for the duration defined in KNOCKBACK_DURATION
	knockback_timer = KNOCKBACK_DURATION


####### LAVA SYSTEM ######
func apply_lava():
	# Slow down the player's speed by reducing the current_speed
	current_speed = SPEED * LAVA_SPEED_FACTOR
	
	# Check if enough time has passed since last damage
	if Time.get_ticks_msec() / 1000.0 - last_damage_time >= damage_interval:
		take_damage(LAVA_DAMAGE)  # Apply damage to the player
		last_damage_time = Time.get_ticks_msec() / 1000.0
	
	fire_sprite.play("on_fire")
	fire_sprite.visible = true
	fire_light.visible = true


func remove_lava():
	if !fire_sprite:
		return
	
	fire_sprite.visible = false
	fire_light.visible = false
	current_speed = SPEED

####### HEALTH SYSTEM #######

func save_player_stats() -> void:
	Globals.current_health = current_health
	Globals.current_oxygen = current_oxygen


# Function to handle when the player takes damage
func take_damage(damage: int) -> void:
	# Reduce the player's current health by the damage amount
	current_health -= damage
	damage_taken.emit()
	
	# If health drops to 0 or below, trigger game over
	if current_health <= 0:
		current_health = 0  # Prevent health from going negative
		game_over()  # Call the game over function
		print("Current Health:", current_health)  # Output current health for debugging

####### RESPAWN/DEATH SYSTEM #######

@onready var spawn_marker = get_node("/root/Environment/SpawnPoint")  # Reference to the Marker2D node
@onready var game_over_screen = get_node("/root/Environment/CanvasLayer/GameOver")  # Reference to the GameOver screen in the hierarchy

# Function to handle respawning the player
func respawn() -> void:
	# Respawn the player at the spawn marker's position
	global_position = spawn_marker.global_position
	# Deactivate oxygen leak, if present upon death
	fix_oxygen_leak()
	# Bug fix workaround. The same rock cannot trigger oxygen drain twice
	get_tree().reload_current_scene()

	## Reset the player's health, oxygen, and other stats upon respawn
	current_health = max_health
	
	## Reset the player's oxygen levels 
	current_oxygen = max_oxygen  
	oxygen_changed.emit()
	
	is_dead = false  # Allow the player to move again
	print("Respawning...")  


# Function to handle the game over state when the player's health reaches 0
func game_over() -> void:
	print("Game Over!")  # Debugging message

	# Play the game over sound ("lego_death.wav")
	var audio_player = get_node("Death_Sound")
	if audio_player:
		#audio_player.play()  # Play the sound
		pass
	
	is_dead = true  # Set the player to dead, disabling further movement
	
	# Show the game over screen by setting it to visible
	game_over_screen.visible = true


# Handle the signal from the death screen to respawn the player
func _on_respawn_signal() -> void:
	print("Respawn signal received!")  # Debugging message to ensure the signal works
	# Hide the game over screen when respawning
	game_over_screen.visible = false
	# maybe unpause the game (if we plan on it) and respawn the player
	respawn()


####### OXYGEN SYSTEM #######

# Function to deplete oxygen over time (called every frame)
func deplete_oxygen(delta: float) -> void:
	var is_in_ship = get_tree().current_scene.name == "Shipinterior"
	var oxygenDrainRate = 2 * delta  # Controls how quickly oxygen drains over time (adjustable)
	var healthDrainRate = 15  # Amount of health to reduce per "tick" when oxygen is depleted
	
	# Only deplete oxygen if leaking and not inside the ship
	if Globals.oxygen_leaking and not is_in_ship:
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
	
	# Send signal to update the oxygen bar and its color to reflect the current oxygen level
	oxygen_changed.emit()


func refill_oxygen(delta: float) -> void:
	var refill_rate = 10 * delta  # Adjust this rate to control how quickly oxygen refills
	current_oxygen = min(current_oxygen + refill_rate, max_oxygen)  # Refill oxygen but do not exceed max
	oxygen_changed.emit()

####### OXYGEN LEAK SYSTEM ######

# Start oxygen leak
func start_oxygen_leak() -> void:
	Globals.oxygen_leaking = true
	# Display and start flickering the warning label
	warning_label.text = "WARNING! Oxygen leak detected!"
	warning_visible = true
	warning_label.visible = true
	
	# Check if the player is inside the ship
	var is_in_ship = get_tree().current_scene.name == "Shipinterior"
	
	if not is_in_ship:
		# Play the warning sound only if not inside the ship
		warning_audio.stream.loop = true
		warning_audio.play()
		leak_audio.stream.loop = true
		leak_audio.play()
	else:
		# Stop the audio inside the ship
		warning_audio.stop()
		warning_audio.stream.loop = false
		leak_audio.stop()
		leak_audio.stream.loop = false 


# Handle flickering of warning text
func handle_warning(delta: float) -> void:
	warning_timer += delta
	if warning_timer >= 0.5:  # Flicker every 0.5 seconds
		warning_visible = not warning_visible  # Toggle visibility
		warning_label.visible = warning_visible
		warning_timer = 0.0


# function to fix the oxygen leak (using duct tape or if you die and respawn)
func fix_oxygen_leak() -> void:
	Globals.oxygen_leaking = false
	warning_label.visible = false  # Hide the warning text

	# Stop the warning sound and disable looping
	warning_audio.stop()
	warning_audio.stream.loop = false
	leak_audio.stop()
	leak_audio.stream.loop = false


####### Resource Management System #######

func on_item_picked_up(item:Item) -> void:
	# Check first to see if the inventory is full
	# If inventory is full, do not pickup item and emit failure
	# Otherwise pickup item and emit success
	
	if !inventory.add_item(item):
		print("Inventory Full!")
		picked_up_item.emit(item, "Inventory Full!\n")
		
	else:
		print("Picked up ", item.name)
		picked_up_item.emit(item, "Picked up " + item.name + ".\n")
		


####### HotBar/Item Use Handling #######

func use_item(item : Item, index : int):
	if item == null:
		print("No item in hotbar!")
		return
	else:
		print("Using ", item.name, "...")

			
	# Handle Item use and animations
	match item.name:
		"Drill":
			if target_rock:
				drilling = true
				
				if last_facing_direction == Vector2.UP:
						$Sprite2D/AnimationPlayer.play("drill_backward")
				if last_facing_direction == Vector2.DOWN:
						$Sprite2D/AnimationPlayer.play("drill_forward")
				if last_facing_direction == Vector2.LEFT:
						$Sprite2D/AnimationPlayer.play("drill_left")
				if last_facing_direction == Vector2.RIGHT:
						$Sprite2D/AnimationPlayer.play("drill_right")
				target_rock.destroy(item)
		"Duct Tape":
			if !Globals.oxygen_leaking:
				return
			$Sprite2D/AnimationPlayer.play("duct_tape")
			fix_oxygen_leak()
			
		"Medkit":
			print(current_health)
			if current_health == max_health:
				return
			$Sprite2D/AnimationPlayer.play("health")
			current_health += item.effect + Globals.medkit_modifier
			damage_taken.emit()
			oxygen_changed.emit()
			print(current_health)
		"Oxygen Tank":
			if current_oxygen == max_oxygen:
				return
			$Sprite2D/AnimationPlayer.play("oxygen")
			current_oxygen += item.effect + Globals.oxygen_modifier
	
	if item.consumable:
		inventory.remove_from_hotbar(index)
	
	hotbar.update_hotbar_ui(inventory)
	damage_taken.emit()
	oxygen_changed.emit()


####### Dynamic Footsteps #######
func footstep_handler() -> void:
	if velocity == Vector2.ZERO:
		return
	
	var footstep_player : AudioStreamPlayer2D = $Footsteps
	var audio_timer : Timer = $Footsteps/Timer
	
	var play = false
	
	match stepping_tile:
		TileDetector.TerrainType.ROCK:
			play = true
		TileDetector.TerrainType.STEEL:
			play = true
	
	if play and audio_timer and audio_timer.time_left <= 0:
		footstep_player.pitch_scale = randf_range(0.8, 1.0)
		footstep_player.play()
		audio_timer.start()


####### LEVEL TRACKING (For later on in the shop) #######

# Method to get the current level
func get_level() -> int:
	return Globals.current_level


func reset_camera() -> void:
	camera.global_position = self.global_position


func stop_movement(arg: String):
	if arg == "false":
		allowed_to_move = false
	elif arg == "true":
		allowed_to_move = true

####### Save Information #######

# Function used in file_manager.gd
func save() -> Dictionary:
	var save_dict = {
		"name" : "Player",
		"filename" : get_scene_file_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"current_health" : current_health,
		"max_health" : max_health,
		"current_oxygen" : current_oxygen,
		"max_oxygen": max_oxygen,
		"is_dead" : is_dead,
		"inventory" : inventory.to_dict(),
		"current_level" : Globals.current_level
	}
	
	return save_dict
