extends Area2D

@export var interact_key: String = "interact"  # Represents the "E" key by default
var player_nearby: bool = false
@onready var shop_ui = get_node("/root/Shipinterior/CanvasLayer/ShopUI")  # Reference to your shop UI node
@onready var player = get_node("/root/Shipinterior/Player")  # Adjust path to your Player node
@onready var interaction_label = player.get_node("InteractionLabel")  # The label over the player's head

# Detect when the player enters the shop computer's area
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):  # Ensure the player is in the player group
		player_nearby = true
		print("Player is near the shop computer. Press E to interact.")
		# Show the message over the player's head
		show_interaction_message("Press E to interact")

# Detect when the player leaves the area
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_nearby = false
		print("Player has left the shop computer area.")
		# Hide the interaction message
		hide_interaction_message()

# Check for the interaction key press
func _process(_delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed(interact_key):
		if shop_ui.visible:
			shop_ui.hide()
		else:
			shop_ui.show()
		print("Shop menu toggled.")  

# Show the interaction message over the player's head
func show_interaction_message(message: String):
	interaction_label.text = message
	interaction_label.visible = true

# Hide the interaction message
func hide_interaction_message():
	interaction_label.visible = false
