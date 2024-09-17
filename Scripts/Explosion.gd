extends Node2D

func _ready():
	print("Explosion created at position: ", global_position)
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	print("Explosion finished at position: ", global_position)
	queue_free()
