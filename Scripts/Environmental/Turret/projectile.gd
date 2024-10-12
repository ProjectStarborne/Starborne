extends CharacterBody2D

var speed = 800.0
var direction = Vector2.ZERO
var lifetime = 10.0
var damage = 20

func _ready():
	# Start the timer for despawning the projectile after its lifetime
	var despawn_timer = Timer.new()
	despawn_timer.wait_time = lifetime
	despawn_timer.one_shot = true
	despawn_timer.timeout.connect(queue_free)
	add_child(despawn_timer)
	despawn_timer.start()
	set_physics_process(true)

# Set direction and speed when the projectile is fired
func set_direction_and_speed(new_direction: Vector2, new_speed: float):
	direction = new_direction.normalized()
	speed = new_speed

# Move the projectile every physics frame
func _physics_process(delta):
	# Move the projectile using move_and_collide
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		#print("Projectile hit something!")

		# Get the object the projectile collided with
		var collider = collision.get_collider()

		# Handle collision with the player
		if collider.name == "Player":
			#print("Projectile hit the player!")
			collider.take_damage(damage)  # Ensure the player has a take_damage method

		# Destroy the projectile on any collision
		queue_free()
