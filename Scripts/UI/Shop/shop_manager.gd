extends Control

@onready var world = get_node("/root/Shipinterior")

#Worlds most simple script, brought to you by yours truly, mark 
func _on_close_button_pressed() -> void:
	world.menu_open = false
	world.current_menu = null
	hide() # Replace with function body.
