extends Area2D

# Knockback strength
var knockback_strength = 200.0  # Adjust this for the amount of knockback
var oxygen_leak_triggered = false  # To track if the oxygen leak has been triggered
var should_delete = false  # Tracks if the rock should be deleted after death

		
func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		print("Player touched the rock!")
		
		# Check if the player's health is above the damage threshold
		if body.current_health > 20:  # Assuming take_damage will reduce by 20
			# Play the meteor_impact.wav sound effect only if it's not fatal
			var audio_player = get_node("AudioStreamPlayer2D")
			if audio_player:
				print("Audio player found!")
				audio_player.play()

		body.take_damage(20)  # Call the take_damage function on the player
		
		# Apply knockback
		apply_knockback(body)
		
		# If the oxygen leak hasn't been triggered, start it
		if not oxygen_leak_triggered:
			body.start_oxygen_leak()  # Trigger the oxygen leak on the player
			oxygen_leak_triggered = true
		
		# Trigger the screen shake
		# Try to find the camera by traversing the scene tree from the Player node
		var camera = body.get_node_or_null("AnchorCamera2D")
		if camera != null:
			camera.start_screen_shake(0.5, 2)  # Shake for 0.5 seconds with intensity 2


# Function to apply knockback to the player
func apply_knockback(player):
	# Calculate the direction from the rock to the player
	var direction = (player.global_position - global_position).normalized()

	# Apply the knockback force
	player.apply_knockback(direction * knockback_strength)
