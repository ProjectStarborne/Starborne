extends Area2D

@export var interact_key: String = "interact"  # represents the "E" key by default
var player_nearby: bool = false
@onready var ship_storage_ui: Control = $"../../CanvasLayer/ShipStorageUI"
@onready var player: Player = get_node("/root/Shipinterior/Player")
@onready var interaction_label = player.get_node("InteractionLabel")


# Detect when the player enters the navigation computer's area
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):  # Ensure the player is in the player group
		player_nearby = true
		print("Player is near the storage locker. Press E to interact.")
		show_interaction_message("Press E to interact")

# Detect when the player leaves the area
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_nearby = false
		print("Player has left the storage locker area.")
		hide_interaction_message()

# Check for the interaction key press
func _process(delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed(interact_key):
		if ship_storage_ui.visible:
			ship_storage_ui.close()
		else:
			ship_storage_ui.open(player.inventory, Globals.ship_inventory)
		print("Storage menu toggled.")

# Show the interaction message over the player's head
func show_interaction_message(message: String):
	interaction_label.text = message
	interaction_label.visible = true

# Hide the interaction message
func hide_interaction_message():
	interaction_label.visible = false
