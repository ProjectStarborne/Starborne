extends Area2D

@export var interact_key: String = "interact"  # Represents the "E" key by default
var player_nearby: bool = false
@onready var shop_ui = get_node("/root/Shipinterior/CanvasLayer/ShopUI")  # Adjusted path to your shop UI node

# Detect when the player enters the shop computer's area
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):  # Ensure the player is in the player group
		player_nearby = true
		print("Player is near the shop computer. Press E to interact.")

# Detect when the player leaves the area
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_nearby = false
		print("Player has left the shop computer area.")

# Check for the interaction key press
func _process(delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed(interact_key):
		if shop_ui.visible:
			shop_ui.hide()
		else:
			shop_ui.show()
		print("Shop menu toggled.")
