extends Area2D

@onready var explosion_scene = preload("res://Scenes/explosion.tscn")  # Preload your explosion scene
@onready var explosion_sound = preload("res://Assets/sounds/explosion_mine.wav")  # Preload your explosion sound
var explosion_delay = 1.5  # Delay in seconds for the explosion (adjust based on audio length)
var damage_radius = 150.0  # Explosion damage radius
var knockback_strength: float = 300.0  # Knockback strength
var explosion_damage = 80
var triggered = false  # To ensure the mine only triggers once

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and not triggered:  # Ensure the explosion triggers only once
		triggered = true
		start_warning_and_explosion()

# Function to start audio warning and trigger explosion after delay
func start_warning_and_explosion():
	# Play explosion warning sound first
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = explosion_sound
	audio_player.global_position = global_position
	get_tree().current_scene.add_child(audio_player)
	audio_player.play()

	# Delay the actual explosion until the audio warning is played
	var timer = Timer.new()
	timer.wait_time = explosion_delay  # Match this delay to the warning duration
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "trigger_explosion"))
	add_child(timer)
	timer.start()

# Function to trigger the explosion after the delay
func trigger_explosion():
	# Spawn explosion at the mine's position
	var explosion_instance = explosion_scene.instantiate()  # For Godot 4.x, use instantiate() instead of instance()
	explosion_instance.global_position = global_position
	get_tree().current_scene.add_child(explosion_instance)

	# Damage the player if they are within the blast radius
	var player = get_tree().current_scene.get_node("Player")  # Adjust the path to the Player node as needed
	if player:
		var distance = player.global_position.distance_to(global_position)
		if distance <= damage_radius:
			# Apply damage to the player
			player.take_damage(explosion_damage)
			
			# Apply knockback effect to the player
			apply_knockback(player)

			# Trigger a screen shake effect on the player's camera
			var camera = player.get_node_or_null("AnchorCamera2D")  # Adjust the path to the player's camera node
			if camera != null:
				camera.start_screen_shake(1.5, 4)  # Shake the screen for 1.0 seconds with intensity 4

	# Remove the mine after exploding
	queue_free()

# Function to apply knockback to the player
func apply_knockback(player):
	# Calculate the direction from the explosion's point to the player's position
	var direction = (player.global_position - global_position).normalized()

	# Apply the knockback force to the player, scaled by the knockback strength
	player.apply_knockback(direction * knockback_strength)
