extends Area2D

# Knockback strength
var knockback_strength = 200.0  # Adjust this for the amount of knockback
		
func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		print("Player touched the rock!")
		body.take_damage(20)  # Call the take_damage function on the player
		# Apply knockback
		apply_knockback(body)
		
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
