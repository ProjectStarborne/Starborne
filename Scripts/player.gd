extends CharacterBody2D

@export var speed = 650
@export var rotation_speed = 2.5
@export var friction = 0.05

func _physics_process(delta: float) -> void:
	var rotation_direction = Input.get_axis("left", "right")
	var direction = Input.get_axis("down", "up")
	
	# Calculations for friction 
	var target_velocity = transform.y * -direction * speed
	velocity += (target_velocity - velocity) * friction
	
	rotation += rotation_direction * rotation_speed * delta
	
	#print("x: ", velocity.x, " y: ", velocity.y)
	move_and_slide()
