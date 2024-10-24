extends StaticBody2D

## The mineral pickup that is dropped 
@export var drop : PackedScene
@onready var player: Player = get_parent().get_node("Player")


	
func destroy():
	var instance = drop.instantiate()
	spawn_item()
	queue_free() # Remove node from scene


func spawn_item():
	var instance = drop.instantiate()
	instance.position = self.position
	
	# Add random movement for pop out effect
	var random_offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
	instance.apply_central_impulse(random_offset)
	
	get_parent().add_child(instance)


func _on_proximity_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Entered node drilling range")
		player.target_rock = self


func _on_proximity_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Exited node drilling range")
		player.target_rock = null
