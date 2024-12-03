extends StaticBody2D

@export var interact_key: String = "interact"  # represents the "E" key by default
var player_nearby: bool = false
@onready var player = get_node("/root/Environment2/Player")  # Update this path to your actual scene structure
@onready var interaction_label = player.get_node("InteractionLabel")

@onready var world = get_node("/root/Shipinterior")


# Detect when the player enters the navigation computer's area
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):  # Ensure the player is in the player group
		player_nearby = true
		print("Player is near overseer. Press E to interact.")
		show_interaction_message("Press E to interact")

# Detect when the player leaves the area
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_nearby = false
		print("Player has left the overseer area.")
		hide_interaction_message()


# Show the interaction message over the player's head
func show_interaction_message(message: String):
	interaction_label.text = message
	interaction_label.visible = true

# Hide the interaction message
func hide_interaction_message():
	interaction_label.visible = false
