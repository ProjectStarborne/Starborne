extends Area2D

var target_position: Vector2 = Vector2.ZERO
@export var speed: float = 1000.0
var velocity: Vector2 = Vector2.ZERO
@onready var ExplosionScene = preload("res://Scenes/explosion.tscn")
var impact_sound = preload("res://Assets/sounds/meteor_impact.wav")
var impact_indicator: Node = null 
var knockback_strength: float = 300.0  # Adjust this for the meteor knockback strength

func _ready() -> void:
	print("Meteor ready at position:", global_position, " with target_position:", target_position)
	if target_position == null or target_position == Vector2.ZERO:
		print("Error: target_position not set for meteor at position:", global_position)
		queue_free()
		return
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	rotation = velocity.angle()


func _physics_process(delta: float) -> void:
	position += velocity * delta
	# Check if the meteor has reached or passed the target position
	if ((velocity.x >= 0 and position.x >= target_position.x) or (velocity.x < 0 and position.x <= target_position.x)) \
	   and ((velocity.y >= 0 and position.y >= target_position.y) or (velocity.y < 0 and position.y <= target_position.y)):
		impact()

func impact():
	# Create explosion effect
	var explosion_instance = ExplosionScene.instantiate()
	explosion_instance.global_position = target_position
	get_tree().current_scene.add_child(explosion_instance)

	# Play impact sound
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = impact_sound
	audio_player.global_position = target_position
	get_tree().current_scene.add_child(audio_player)
	audio_player.play()
	
	if impact_indicator:
		impact_indicator.queue_free()

	# Damage the player if nearby
	var player = get_tree().current_scene.get_node("Player")  # Adjust the path
	var damage_radius = 100.0  # Adjust as needed

	if player:
		var distance = player.global_position.distance_to(target_position)
		if distance <= damage_radius:
			player.take_damage(40)
			# Apply knockback or other effects
			# Apply knockback
			apply_knockback(player)

			# Trigger the screen shake
			var camera = player.get_node_or_null("AnchorCamera2D")  # Adjust path to player's camera node
			if camera != null:
				camera.start_screen_shake(0.5, 2)  # Shake for 0.5 seconds with intensity 2

	# Remove the meteor
	queue_free()


# Function to apply knockback to the player
func apply_knockback(player):
	# Calculate the direction from the meteor to the player
	var direction = (player.global_position - target_position).normalized()

	# Apply the knockback force to the player
	player.apply_knockback(direction * knockback_strength)
