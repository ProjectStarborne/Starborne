extends Area2D

var target_position: Vector2 = Vector2.ZERO
@export var speed: float = 1000.0
var velocity: Vector2 = Vector2.ZERO
@onready var ExplosionScene = preload("res://Scenes/explosion.tscn")
var impact_sound = preload("res://Assets/sounds/meteor_impact.wav")

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

	# Damage the player if nearby
	var player = get_tree().current_scene.get_node("Player")  # Adjust the path
	var damage_radius = 100.0  # Adjust as needed

	if player:
		var distance = player.global_position.distance_to(target_position)
		if distance <= damage_radius:
			player.take_damage(40)
			# Apply knockback or other effects

	# Remove the meteor
	queue_free()
