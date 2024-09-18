extends Node2D

@export var item:Item

# Loads items into the scene and instantiates them on startup
func _ready() -> void:
	# Load scene from database (see items.gd)
	var instance = item.scene.instantiate()
	add_child(instance)
	print("Item Position: ", instance.global_position)

# If the player gets close enough, the item will be picked up and then removed from the scene
func _on_area_2d_body_entered(body: Node2D) -> void:
	# Check if there is a function in the body's script called on_item_picked_up
	if body.has_method("on_item_picked_up"):
		# Call that function with the item_id
		body.on_item_picked_up(item)
		# Remove the node from the scene
		queue_free()
