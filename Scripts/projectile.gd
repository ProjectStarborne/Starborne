extends CharacterBody2D  # Using CharacterBody2D for physics-based movement

var speed = 300.0
var direction = Vector2.ZERO
var lifetime = 10.0  # Time in seconds before the projectile despawns
var damage = 20  # Damage the projectile deals to the player

func _ready():
	# Start the timer for despawning the projectile after its lifetime
	var despawn_timer = Timer.new()
	despawn_timer.wait_time = lifetime
	despawn_timer.one_shot = true
	despawn_timer.connect("timeout", Callable(self, "queue_free"))
	add_child(despawn_timer)
	despawn_timer.start()
	set_physics_process(true)

# Set direction and speed when the projectile is fired
func set_direction_and_speed(new_direction: Vector2, new_speed: float):
	direction = new_direction
	speed = new_speed

# Move the projectile every frame
func _physics_process(delta: float) -> void:
	# Move the projectile using move_and_collide
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		print("Projectile hit something!")
		
		# Get the object the projectile collided with
		var collider = collision.get_collider()
		
		# Handle collision with the player
		if collider.name == "Player":
			print("Projectile hit the player!")
			collider.take_damage(damage)  # Apply damage to the player
		
		# Destroy the projectile on any collision
		queue_free()
