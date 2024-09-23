extends Node2D

@export var projectile_scene = preload("res://Scenes/projectile.tscn")  # path to our projectile scene
@onready var gunshot_sound = preload("res://Assets/sounds/gunshot.wav")
@export var shoot_interval = 2.0  # time between shots
@export var projectile_speed = 800.0  # speed of the projectile
@export var detection_radius = 200.0  # detection range for the player
@export var turret_damage = 10  # damage caused by the projectile

var player = null  # Reference to the player
var shoot_timer = 0.0

func _process(delta: float) -> void:
	if player:
		# rotate turret towards the player lol it looks dumb but it works
		look_at(player.global_position)
		
		# shoot at intervals
		shoot_timer += delta
		if shoot_timer >= shoot_interval:
			shoot_projectile()
			shoot_timer = 0.0


# function to shoot a projectile
func shoot_projectile():
	var projectile = projectile_scene.instantiate()

	# apply an offset to simulate the projectile spawning from the turret's barrel
	var offset = Vector2(45, -20)  
	projectile.global_position = global_position + offset.rotated(rotation)

	get_tree().current_scene.add_child(projectile)
	print("Projectile spawned at position: ", projectile.global_position)  # debugging projectile creation
	
	# calculate direction towards the player
	var direction = (player.global_position - global_position).normalized()
	projectile.set_direction_and_speed(direction, projectile_speed)
	
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = gunshot_sound
	audio_player.global_position = global_position
	get_tree().current_scene.add_child(audio_player)
	audio_player.play()



# when the player enters the detection area
func _on_body_entered(body):
	if body.name == "Player":  # adjust the condition to match your player node
		print("Player entered turret detection radius")
		player = body

# When the player exits the detection area
func _on_body_exited(body):
	if body == player:
		print("Player exited turret detection radius")
		player = null
