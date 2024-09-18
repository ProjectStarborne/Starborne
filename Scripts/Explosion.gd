extends Node2D

# Called when the explosion animation node is added to the scene
func _ready():
	# Print a message to the console showing the position of the explosion when it's created
	print("Explosion created at position: ", global_position)

	# Play the explosion animation on the AnimatedSprite2D node
	$AnimatedSprite2D.play()

	# Connect the "animation_finished" signal to the _on_animation_finished function
	# This will trigger the function when the animation finishes playing
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)


# Function called when the explosion animation finishes
func _on_animation_finished():
	# Print a message to the console indicating that the explosion animation has completed
	print("Explosion finished at position: ", global_position)

	# Safely remove the explosion node from the scene after the animation ends
	queue_free()
