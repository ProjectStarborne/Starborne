extends Node2D

var speed = 300.0
var direction = Vector2.ZERO
var lifetime = 10.0  # time in seconds before the projectile despawns
var damage = 20  # damage the projectile deals to the player

func _ready():
	# start the timer for despawning the projectile after its lifetime
	var despawn_timer = Timer.new()
	despawn_timer.wait_time = lifetime
	despawn_timer.one_shot = true
	despawn_timer.connect("timeout", Callable(self, "queue_free"))
	add_child(despawn_timer)
	despawn_timer.start()
	set_physics_process(true)

# set direction and speed when the projectile is fired
func set_direction_and_speed(new_direction: Vector2, new_speed: float):
	direction = new_direction
	speed = new_speed

# move the projectile every frame
func _physics_process(delta: float) -> void:
	position += direction * speed * delta

# handle collisions with the player or other objects
func _on_body_entered(body: Node) -> void:
	if body.name == "Player":  # ensure checking for the correct player node
		print("Projectile hit the player!")
		body.take_damage(damage)  # apply damage on the player
		queue_free()  # destroy the projectile after it hits the player

	# also need to consider if it hits walls 
