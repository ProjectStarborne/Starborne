extends Area2D

@export var speed: float = 250.0  # Speed of the meteor falling
@export var level_bottom: float = 3000.0 
var velocity: Vector2 = Vector2.ZERO

# Knockback strength
var knockback_strength = 300.0  # Adjust this for the amount of knockback

func _ready() -> void:
	# Set the initial velocity (falling downwards)
	velocity = Vector2(0, speed)
	# Optionally, add rotation or other effects here

func _physics_process(delta: float) -> void:
	# Move the meteor downwards
	position += velocity * delta
	# Remove the meteor if it goes off-screen
	if position.y > level_bottom:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage(40)  # Adjust damage amount as needed
		apply_knockback(body)
		
		# triggering the screen shake
		# try to find the camera by traversing the scene tree from the Player node
		var camera = body.get_node_or_null("AnchorCamera2D")
		if camera != null:
			camera.start_screen_shake(0.5, 20)  # shakeeeee for 0.5 seconds with intensity 20
			
		# optionally, we could create an explosion effect here
		
		# play the meteor_impact.wav sound effect
		var audio_player = get_node("AudioStreamPlayer2D")
		if audio_player:
			print("Audio player found!")
			audio_player.play()

			# detach the sound node from the meteor so it keeps playing even after the meteor is removed
			#some dumb bug workaround, it works
			audio_player.get_parent().remove_child(audio_player)
			get_tree().root.add_child(audio_player)

		# stop the meteor's movement immediately and remove it
		queue_free()  # remove the meteor after collision


# function to apply knockback to the player
func apply_knockback(player):
	# valculate the direction from the rock to the player
	var direction = (player.global_position - global_position).normalized()
	# apply the knockback force
	player.apply_knockback(direction * knockback_strength)
