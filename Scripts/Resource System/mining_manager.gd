extends StaticBody2D

## The mineral pickup that is dropped 
@export var drop : PackedScene
@onready var player: Player = get_parent().get_node("Player")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var animation_weight = 1.0
@export var required_level = 1

signal ore_destroyed(item : Item)
signal upgrade_notif(item, fail, msg)

func destroy(item : Item):
	if item.level >= required_level:
		var speed = animation_weight * item.weight
		animation_player.play("mine", -1, speed)
		await animation_player.animation_finished
		
		if drop != null :
			var instance = drop.instantiate()
			spawn_item()
		
		queue_free() # Remove node from scene
		
		# Tell connected nodes that this ore was destroyed.
		ore_destroyed.emit(item)
	else:
		var msg = "Player not able to mine! Not at suitable level!\n"
		print(msg)
		upgrade_notif.emit(item, msg)
		


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
