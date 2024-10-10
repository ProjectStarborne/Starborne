extends Node2D

@onready var explosion_light = $PointLight2D

func _ready():
	# Play the explosion animation
	$AnimatedSprite2D.play()
	
	$AnimationPlayer.play("ExplosionLight")
	
	# Connect the animation_finished signal
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	# Remove the explosion node from the scene after the animation ends
	queue_free()
