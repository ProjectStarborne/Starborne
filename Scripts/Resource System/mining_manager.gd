extends StaticBody2D

## The mineral pickup that is dropped 
@export var drop : PackedScene
@onready var player = %Player

func destroy():
	var instance = drop.instantiate()
	add_child(instance)
	queue_free()


func _on_proximity_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Entered node drilling range")
		player.target_rock = self


func _on_proximity_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Exited node drilling range")
		player.target_rock = null
