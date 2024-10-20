extends Control

signal respawn_signal  # Defining a signal to notify other scripts

func _on_return_to_ship_pressed() -> void:
	print("return button pressed")
	# Emit a signal to the player or the main game script to handle the respawn
	emit_signal("respawn_signal")
	# Remove the game over screen from the scene tree
	self.visible = false  # Hide the game over screen instead of removing it


func _on_quit_pressed() -> void:
	get_tree().quit()
