extends Control

@onready var grid_container = $VBoxContainer/ScrollContainer/GridContainer
@onready var click_sound = $KeyboardClick  # The AudioStreamPlayer node for the sound effect

func _ready():
	populate_travel_buttons()


# Function to populate the UI with travel buttons and connect signals
func populate_travel_buttons():
	for i in range(grid_container.get_child_count()):
		var level_box = grid_container.get_child(i) as HBoxContainer
		var vbox_container = level_box.get_node("VBoxContainer") as VBoxContainer
		var travel_button = level_box.get_node("Travel") as Button

		if travel_button == null:
			print("Error: Travel button not found in ", level_box.name)
			continue

		var level_label = vbox_container.get_node("Level") as Label
		travel_button.set_meta("level", level_label.text)

		var press_signal = Callable(self, "_on_travel_button_pressed")
		if travel_button.is_connected("pressed", press_signal):
			travel_button.disconnect("pressed", press_signal)

		travel_button.pressed.connect(press_signal.bind(travel_button))
		travel_button.connect("mouse_entered", Callable(self, "_on_travel_button_mouse_entered").bind(travel_button))
		travel_button.connect("mouse_exited", Callable(self, "_on_travel_button_mouse_exited").bind(travel_button))


# Handle button pressed logic
func _on_travel_button_pressed(travel_button: Button) -> void:
	var level_label = travel_button.get_meta("level")
	var level = level_label.replace("Level ", "")
	
	# Check for required upgrades for each level
	match level:
		"2":
			if !Globals.upgrades_purchased["Warp Engine V.1"]:
				display_popup_message("You need Warp Engine V.1 to travel to Level 2.")
				return
		"3":
			if !Globals.upgrades_purchased["Fuel Efficiency Module V.1"]:
				display_popup_message("You need Fuel Efficiency Module V.1 to travel to Level 3.")
				return
		"4":
			if !Globals.upgrades_purchased["Stellar Cartography Module"]:
				display_popup_message("You need Stellar Cartography Module to travel to Level 4.")
				return
		"5":
			if !Globals.upgrades_purchased["Reinforced Hull Plating"]:
				display_popup_message("You need Reinforced Hull Plating to travel to Level 5.")
				return
		"6":
			if !Globals.upgrades_purchased["Warp Engine V.2"]:
				display_popup_message("You need Warp Engine V.2 to travel to Level 6.")
				return
		"7":
			if !Globals.upgrades_purchased["Deep Space Scanners"]:
				display_popup_message("You need Deep Space Scanners to travel to Level 7.")
				return
		"8":
			if !Globals.upgrades_purchased["Dark Matter Fuel Cells"]:
				display_popup_message("You need Dark Matter Fuel Cells to travel to Level 8.")
				return
		_:
			display_popup_message("Invalid level or no upgrade needed for this level.")
	
	print("Travel button to level ", level, " pressed")
	change_level(level)




# Function to change the level
func change_level(level: String) -> void:
	# Use the NavigationManager to transition to the new level
	var level_tag = determine_level_tag(level)
	
	if level_tag != "":
		NavigationManager.go_to_level(level_tag, "some_default_door")  # Replace "some_default_door" with a real tag if needed
	else:
		print("Error: Invalid level tag for level ", level)


# Helper function to determine the level tag based on the level number
func determine_level_tag(level: String) -> String:
	match level:
		"1":
			return "world_space"
		"2":
			return "world_asteroid"
		# Add more levels here as needed
		_:
			return ""



# Handle mouse entered (hover) logic
func _on_travel_button_mouse_entered(travel_button: Button) -> void:
	click_sound.play()  # Play the sound effect when the mouse enters the button


# Handle mouse exited (hover exit) logic
func _on_travel_button_mouse_exited(travel_button: Button) -> void:
	pass


func _on_close_button_pressed() -> void:
	hide()

# Display a message in the popup label
func display_popup_message(message: String):
	var popup_label = $BrokeAlert  # Adjust the path to the label
	popup_label.text = message
	popup_label.visible = true
	await get_tree().create_timer(2.0).timeout  # Show message for 2 seconds
	popup_label.visible = false
