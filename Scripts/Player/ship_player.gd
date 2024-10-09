extends CharacterBody2D

# Constants
const SPEED = 60.0 # Normal speed of the player
const NORMAL_FRICTION = 1500.0 
const ICE_FRICTION = 100.0  # Low friction for sliding on ice

# Exported variable for friction, which controls how quickly the player slows down after moving
@export var friction = NORMAL_FRICTION
# Vector to hold the player's knockback velocity (force applied when hit)
var knockback_velocity = Vector2.ZERO
# Timer to track how long the knockback effect lasts
var knockback_timer = 0.0
# Constant defining the duration of the knockback effect (0.5 seconds in this case)
const KNOCKBACK_DURATION = 0.5

#Oxygen leak system variables
var oxygen_leaking = false  # Track if oxygen is leaking
var oxygen_leak_rate_multiplier = 2.0  # Rate multiplier for faster oxygen depletion
var warning_timer = 0.0  # Timer to control warning text flickers
var warning_visible = false  # To track if warning text is currently visible
@onready var warning_label = get_node("/root/Environment/CanvasLayer/OxygenLeakWarning")  # Reference to warning label in UI
@onready var warning_audio = get_node("/root/Environment/CanvasLayer/OxygenLeakWarning/Oxygen_Warning")  # Warning sound player


@onready var flashlight: PointLight2D = $Flashlight
signal picked_up_item(item : Item)

func _physics_process(delta: float) -> void:
	# Initialize a direction vector to store player input
	var direction = Vector2.ZERO


	# Check if the player is dead, and prevent movement if so
	# Check if the player is currently in the knockback state
	if knockback_timer > 0:
		# Apply the knockback force by setting the player's velocity to knockback_velocity
		velocity = knockback_velocity
		# Reduce the knockback timer as time progresses
		knockback_timer -= delta
	else:
		# Reset knockback velocity when knockback is finished
		knockback_velocity = Vector2.ZERO

		# Get the player input for movement
		if Input.is_action_pressed("up"):
			direction.y -= 1  # Move up
			$Sprite2D/AnimationPlayer.play("walk_up")
		if Input.is_action_pressed("down"):
			direction.y += 1  # Move down
			$Sprite2D/AnimationPlayer.play("walk_down")
		if Input.is_action_pressed("left"):
			direction.x -= 1  # Move left
			if direction.y == 0:
				$Sprite2D/AnimationPlayer.play("walk_left")
		if Input.is_action_pressed("right"):
			direction.x += 1  # Move right
			if direction.y == 0:
				$Sprite2D/AnimationPlayer.play("walk_right")

		# Normalize the direction vector for consistent movement speed
		direction = direction.normalized()

		# Update velocity based on direction and apply friction when there's no input
		if direction != Vector2.ZERO:
			velocity = direction * SPEED
		else:
			# Apply friction to slow down when there's no input
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	

	# Stop animations if there's no movement
	if direction == Vector2.ZERO:
		$Sprite2D/AnimationPlayer.stop()



	# Move the player based on the current velocity
	move_and_slide()
