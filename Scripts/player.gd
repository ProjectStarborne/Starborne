extends CharacterBody2D


const SPEED = 50.0
@export var friction = 500

func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if Input.is_action_pressed("up"):
		direction.y = -1
	if Input.is_action_pressed("down"):
		direction.y = 1
	if Input.is_action_pressed("left"):
		direction.x = -1
	if Input.is_action_pressed("right"):
		direction.x = 1
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		
	velocity.x = direction.x * SPEED
	velocity.y = direction.y * SPEED

		
	#print("x: ", velocity.x, " y: ", velocity.y)
	move_and_slide()
