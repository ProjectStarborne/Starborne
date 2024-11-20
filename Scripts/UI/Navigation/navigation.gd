extends Control
class_name Navigation
@onready var grid_container = $VBoxContainer/ScrollContainer/GridContainer
@onready var click_sound = $KeyboardClick  # The AudioStreamPlayer node for the sound effect
@onready var player = get_node("%Player")  # Adjust the path to your player node
@onready var ship_interior_node = get_node_or_null("/root/Shipinterior")  # Adjust this path to your Shipinterior 2D node

# Variables for screen shake
var shake_timer = 0.0
var shake_intensity = 0.0
var original_position = Vector2.ZERO

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
	
	# Check if the player is already at the selected level
	if Globals.current_level == int(level):  # Compare against the selected level
		display_popup_message("You're already at your destination.")
		return
		
	# Check for required upgrades for each level
	match level:
		"1":
			if !Globals.upgrades_purchased["Warp Engine V.1"]:
				display_popup_message("You need Warp Engine V.1 to travel to Level 1.")
				return
		"2":
			if !Globals.upgrades_purchased["Fuel Efficiency Module V.1"]:
				display_popup_message("You need Fuel Efficiency Module V.1 to travel to Level 2.")
				return
		"3":
			if !Globals.upgrades_purchased["Stellar Cartography Module"]:
				display_popup_message("You need Stellar Cartography Module to travel to Level 3.")
				return
		"4":
			if !Globals.upgrades_purchased["Reinforced Hull Plating"]:
				display_popup_message("You need Reinforced Hull Plating to travel to Level 4.")
				return
		"5":
			if !Globals.upgrades_purchased["Warp Engine V.2"]:
				display_popup_message("You need Warp Engine V.2 to travel to Level 5.")
				return
		"6":
			if !Globals.upgrades_purchased["Deep Space Scanners"]:
				display_popup_message("You need Deep Space Scanners to travel to Level 6.")
				return
		"7":
			if !Globals.upgrades_purchased["Dark Matter Fuel Cells"]:
				display_popup_message("You need Dark Matter Fuel Cells to travel to Level 7.")
				return
		_:
			display_popup_message("Invalid level or no upgrade needed for this level.")
	
	# Close the navigation menu
	var navigation_menu = $"."  # Adjust this path to your node
	if navigation_menu != null:
		navigation_menu.visible = false  # Hide the terminal screen before shaking
	
	# Initialize screen shake effect
	if ship_interior_node != null:
		start_screen_shake(10.0, 0.5)  # Adjust intensity and duration as needed
		Globals.is_shaking = true
	else:
		print("Error: 'Shipinterior' node not found!")

	# Set the next level to be loaded upon exiting the ship
	Globals.next_level = determine_level_tag(level)
	
	# Update the current level in Globals to the new level
	Globals.current_level = int(level)
	display_popup_message("Traveling to level " + level + "...")

# Screen shake logic for ship interior scene
func start_screen_shake(duration: float, intensity: float) -> void:
	shake_timer = duration
	shake_intensity = intensity
	original_position = ship_interior_node.position  # Store the original position of the Shipinterior node
	set_process(true)  # Enable processing to update the shake

func _process(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		ship_interior_node.position = original_position + shake_offset  # Apply the shake offset
	else:
		# Reset to the original position when shake is done
		if ship_interior_node != null:
			ship_interior_node.position = original_position
		set_process(false)  # Stop processing to save resources when shake is complete
		Globals.is_shaking = false  # Reset is_shaking when shake is complete

# Helper function to determine the level tag based on the level number
func determine_level_tag(level: String) -> String:
	match level:
		"1":
			return "world_space"
		"2":
			return "world_asteroid"
		"3":
			return "asteroid_two"
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
