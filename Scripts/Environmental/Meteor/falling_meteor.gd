extends Area2D

# The target position where the meteor is aiming to land
var target_position: Vector2 = Vector2.ZERO
# The speed at which the meteor travels (can be adjusted for faster or slower meteors)
@export var speed: float = 1000.0
# Velocity vector to store the current speed and direction of the meteor
var velocity: Vector2 = Vector2.ZERO
# Preload the explosion scene that will be instantiated when the meteor hits the target
@onready var ExplosionScene = preload("res://Scenes/Environmental/Meteor/explosion.tscn")
# Preload the sound effect for the meteor impact
var impact_sound = preload("res://Assets/sounds/meteor_impact.wav")
# Variable to store the impact indicator instance (optional)
var impact_indicator: Node = null 
# Knockback strength to be applied to the player when hit by the meteor (adjustable)
var knockback_strength: float = 300.0


# Called when the meteor node is added to the scene
func _ready() -> void:
	# Print the current meteor position and the target position (for debugging)
	#print("Meteor ready at position:", global_position, " with target_position:", target_position)
	
	# Check if the target position is valid; if not, free the meteor node
	if target_position == null or target_position == Vector2.ZERO:
		print("Error: target_position not set for meteor at position:", global_position)
		queue_free()  # Remove the meteor from the scene
		return
	
	# Calculate the direction from the meteor's current position to the target position
	var direction = (target_position - global_position).normalized()

	# Set the velocity of the meteor based on its speed and direction
	velocity = direction * speed

	# Rotate the meteor to face the direction of travel
	rotation = velocity.angle()


# Called every frame to update the meteor's position
func _physics_process(delta: float) -> void:
	# Update the meteor's position based on its velocity and the time delta
	position += velocity * delta
	
	# Check if the meteor has reached or passed the target position (on both X and Y axes)
	if ((velocity.x >= 0 and position.x >= target_position.x) or (velocity.x < 0 and position.x <= target_position.x)) \
	   and ((velocity.y >= 0 and position.y >= target_position.y) or (velocity.y < 0 and position.y <= target_position.y)):
		# Call the impact function when the meteor reaches its target
		impact()


# Function called when the meteor reaches its target position
func impact():
	# Create the explosion effect at the target position
	var explosion_instance = ExplosionScene.instantiate()
	explosion_instance.global_position = target_position
	get_tree().current_scene.add_child(explosion_instance)  # Add the explosion to the current scene
	print("Explosion at:", explosion_instance.global_position)

	# Create and play the impact sound at the target position
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = impact_sound
	audio_player.global_position = target_position
	get_tree().current_scene.add_child(audio_player)
	audio_player.play()

	# Remove the impact indicator (if it exists) once the meteor hits
	if is_instance_valid(impact_indicator):
		impact_indicator.queue_free()
		impact_indicator = null


	# Damage the player if they are within the blast radius
	var player = get_tree().current_scene.get_node("Player")  # Adjust the path to the Player node as needed
	var damage_radius = 100.0  # Set the damage radius for the meteor's impact
	
	# Check if the player is close enough to the impact point
	if player:
		var distance = player.global_position.distance_to(target_position)
		if distance <= damage_radius:
			# Apply damage to the player
			player.take_damage(45)
			
			# Apply knockback effect to the player
			apply_knockback(player)

			# Trigger a screen shake effect on the player's camera 
			var camera = player.get_node_or_null("AnchorCamera2D")  # Adjust the path to the player's camera node
			if camera != null:
				camera.start_screen_shake(1.5, 4)  # Shake the screen for 1.0 seconds with intensity 4

	# Remove the meteor from the scene after it impacts
	queue_free()


# Function to apply knockback to the player when hit by the meteor
func apply_knockback(player):
	# Calculate the direction from the meteor's impact point to the player's position
	var direction = (player.global_position - target_position).normalized()

	# Apply the knockback force to the player, scaled by the knockback strength
	player.apply_knockback(direction * knockback_strength)
