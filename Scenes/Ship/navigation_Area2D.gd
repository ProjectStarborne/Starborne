extends Area2D

@export var interact_key: String = "interact"  # represents the "E" key by default
var player_nearby: bool = false
@onready var navigation_ui = $"/root/Shipinterior/CanvasLayer/Navigation"
 

# Detect when the player enters the navigation computer's area
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):  # Ensure the player is in the player group
		player_nearby = true
		print("Player is near the navigation computer. Press E to interact.")

# Detect when the player leaves the area
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_nearby = false
		print("Player has left the navigation computer area.")

# Check for the interaction key press
func _process(delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed(interact_key):
		if navigation_ui.visible:
			navigation_ui.hide()
		else:
			navigation_ui.show()
		print("Navigation menu toggled.")
