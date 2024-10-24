extends Area2D

@export var projectile_scene = preload("res://Scenes/Environmental/Turret/projectile.tscn")
@export var shoot_interval = 2.0
@export var projectile_speed = 1000.0
@export var turret_damage = 10

@onready var gunshot_sound = preload("res://Assets/sounds/gunshot.wav")
@onready var barrel = $Barrel
@onready var barrel_tip = barrel.get_node("BarrelTip")
@onready var raycast = barrel.get_node("RayCast2D")  # Get reference to RayCast2D node
@onready var laser = barrel.get_node("Line2D")  # Reference to the Line2D node

var player = null
var shoot_timer = 0.0
var smooth_factor = 5.0  # Lower value = smoother rotation

func _process(delta):
	if player:
		# Convert the player's global position to the barrel's local coordinate system
		var local_player_pos = barrel.to_local(player.global_position)
		var angle_to_player = local_player_pos.angle()

		# Define the minimum and maximum rotation angles in radians
		var min_angle = deg_to_rad(-30)
		var max_angle = deg_to_rad(30)

		# Clamp the angle within the specified range
		var clamped_angle = clamp(angle_to_player, min_angle, max_angle)

		# Set the barrel's rotation
		barrel.rotation = lerp_angle(barrel.rotation, clamped_angle, delta * smooth_factor)

		# Update the RayCast2D's target position based on barrel rotation
		raycast.target_position = Vector2(1000, 0).rotated(barrel.rotation)

		# Update the laser's start and end points based on the ray's position and length
		laser.clear_points()
		laser.add_point(Vector2.ZERO)  # Start of the laser at barrel tip
		if raycast.is_colliding():
			# If the ray collides, draw the laser up to the collision point
			var collision_point = raycast.get_collision_point()
			laser.add_point(barrel.to_local(collision_point))
		else:
			# If no collision, draw the laser to its max length (1000 units in the direction of the barrel)
			laser.add_point(Vector2(1000, 0).rotated(barrel.rotation))

		# Check if the RayCast2D is colliding with the player or any obstacles
		if raycast.is_colliding():
			var collider = raycast.get_collider()

			# Check if collider is valid (not null) before accessing its properties. Otherwise it would crash occasionally
			if collider != null:
				# Uncomment or remove the following line if needed in the future:
				# pass
				if collider.name == "Player":
					# Player is in line of sight
					shoot_timer += delta
					if shoot_timer >= shoot_interval:
						shoot_projectile()
						shoot_timer = 0.0
				else:
					# Obstacle detected, not shooting
					pass
			else:
				# Raycast detected a collision but collider is null. Not shooting
				pass
		else:
			# Raycast is not colliding with anything
			pass
			# If no obstacle is detected, shoot at the player as long as they're within range
			shoot_timer += delta
			if shoot_timer >= shoot_interval:
				shoot_projectile()
				shoot_timer = 0.0



func shoot_projectile():
	var projectile = projectile_scene.instantiate()

	# Set the projectile's position to the barrel tip's global position
	projectile.global_position = barrel_tip.global_position

	# Calculate the direction towards the player's center based on position, not rotation
	var direction = (player.global_position - barrel_tip.global_position).normalized()
	
	# Get the current barrel's angle to the player
	var player_angle_to_barrel = (player.global_position - barrel.global_position).angle()
	
	# Define the minimum and maximum rotation angles in radians (same as used in barrel rotation)
	var min_angle = deg_to_rad(-30)  # Minimum angle for the barrel rotation
	var max_angle = deg_to_rad(30)   # Maximum angle for the barrel rotation
	
	# Check if the player's angle is outside the barrel's rotation limits
	if player_angle_to_barrel < min_angle or player_angle_to_barrel > max_angle:
		# If outside, use the barrel's current rotation to determine projectile direction
		#print("Player is outside turret's rotation range. Using barrel's current rotation.")
		direction = Vector2(cos(barrel.rotation), sin(barrel.rotation)).normalized()
	else:
		#print("Player is within turret's rotation range. Using player direction.")
		pass
	
	projectile.set_direction_and_speed(direction, projectile_speed)

	# Add the projectile to the current scene
	get_tree().current_scene.add_child(projectile)

	# Play the gunshot sound
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.volume_db = -20.0
	audio_player.stream = gunshot_sound
	audio_player.global_position = barrel_tip.global_position
	get_tree().current_scene.add_child(audio_player)
	audio_player.play()

# Signal callback when a body enters the Barrel's detection area
func _on_barrel_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		#print("Player entered turret detection radius")
		player = body

# Signal callback when a body exits the Barrel's detection area
func _on_barrel_body_exited(body: Node2D) -> void:
	if body == player:
		#print("Player exited turret detection radius")
		player = null
