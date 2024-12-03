extends Control
class_name Navigation

@onready var grid_container = $ScrollContainer/GridContainer
@onready var click_sound = $"../../KeyboardClick"  # The AudioStreamPlayer node for the sound effect
@onready var player = get_node("%Player")  # Adjust the path to your player node
@onready var ship_interior_node = get_node_or_null("/root/Shipinterior")  # Adjust this path to your Shipinterior 2D node
@onready var navigation_manager = get_parent().get_parent()
@onready var wormhole_background = null

# Variables for screen shake
var shake_timer = 0.0
var shake_intensity = 0.0
var original_position = Vector2.ZERO

# Timers for controlling the wormhole effect
var travel_timer: Timer  # A timer to control the duration
var fade_timer: Timer  # A timer for fading in/out
var update_timer: Timer  # A timer to update the shader's time parameter

# Variable to track elapsed time manually
var elapsed_time = 0.0

func _ready():
	# Populate travel buttons
	populate_travel_buttons()
	
	# Search for Background in parent hierarchy
	var parent = get_parent()
	while parent != null:
		if parent.has_node("Background"):
			wormhole_background = parent.get_node("Background") as ColorRect
			break
		parent = parent.get_parent()

	if wormhole_background == null:
		print("Error: Could not find Background node in parent hierarchy.")
	else:
		print("Found Background!")
		if wormhole_background.material is ShaderMaterial:
			# Duplicate the ShaderMaterial to ensure a unique instance
			wormhole_background.material = wormhole_background.material.duplicate() as ShaderMaterial
			# Initialize shader parameters using set_shader_parameter
			wormhole_background.material.set_shader_parameter("intensity", 0.0)
			wormhole_background.material.set_shader_parameter("time", 0.0)
			print("Shader parameters initialized.")
		else:
			print("Error: Background node does not have a ShaderMaterial assigned.")
	
	# Initialize the travel timer (10 seconds)
	travel_timer = Timer.new()
	add_child(travel_timer)
	travel_timer.wait_time = 10.0
	travel_timer.one_shot = true
	travel_timer.connect("timeout", Callable(self, "end_travel_effect"))
	
	# Initialize the update timer (for shader time updates)
	update_timer = Timer.new()
	add_child(update_timer)
	update_timer.wait_time = 0.05
	update_timer.one_shot = false
	update_timer.connect("timeout", Callable(self, "_update_travel_effect"))
	# Do not start update_timer yet; it will be started when the effect begins

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
			return
	
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
	
	# Start the wormhole effect
	start_travel_effect()
	
	# Close the entire navigation manager
	if navigation_manager != null:
		navigation_manager.hide()

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
			return "world_asteroid"
		"2":
			return "asteroid_two"
		"3":
			return "asteroid_three"
		"4":
			return "final_level"
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
	var popup_label = $"../../BrokeAlert"  # Adjust the path to the label
	popup_label.text = message
	popup_label.visible = true
	await get_tree().create_timer(2.0).timeout  # Show message for 2 seconds
	popup_label.visible = false

###### WORMHOLE CODE #######

func start_travel_effect():
	if wormhole_background == null:
		print("Error: 'wormhole_background' is null.")
		return
	
	# Ensure shader parameters are initialized using set_shader_parameter
	wormhole_background.material.set_shader_parameter("intensity", 0.0)
	wormhole_background.material.set_shader_parameter("time", 0.0)
	
	# Reset elapsed_time
	elapsed_time = 0.0
	
	# Start the fade-in
	fade_timer = Timer.new()
	add_child(fade_timer)
	fade_timer.wait_time = 0.05
	fade_timer.one_shot = false
	fade_timer.connect("timeout", Callable(self, "_fade_in_effect"))
	fade_timer.start()
	
	# Start the travel timer for 10 seconds
	travel_timer.start()
	
	# Start updating the 'time' uniform
	update_timer.start()

func _fade_in_effect():
	if wormhole_background == null or wormhole_background.material == null:
		print("Error: 'wormhole_background' or its material is null.")
		return
	
	# Gradually increase intensity
	var intensity = wormhole_background.material.get_shader_parameter("intensity")
	if intensity == null:
		intensity = 0.0  # Initialize intensity if it's null
	
	if intensity < 1.0:
		intensity += 0.05
		intensity = clamp(intensity, 0.0, 1.0)
		wormhole_background.material.set_shader_parameter("intensity", intensity)
		print("Increasing intensity to ", intensity)
	else:
		# Stop the fade-in once fully visible
		fade_timer.stop()
		fade_timer.queue_free()
		print("Fade-in complete. Intensity is now 1.0")

func _update_travel_effect():
	if wormhole_background.material is ShaderMaterial:
		# Manually track elapsed_time
		elapsed_time += update_timer.wait_time
		wormhole_background.material.set_shader_parameter("time", elapsed_time)
		#print("Updating time to ", elapsed_time)  # Uncomment for debugging
	else:
		print("Error: 'wormhole_background' material is not a ShaderMaterial.")

func end_travel_effect():
	if wormhole_background == null:
		print("Error: 'wormhole_background' is null.")
		return
	
	# Stop updating the 'time' uniform
	update_timer.stop()
	
	# Start fading out the effect
	fade_timer = Timer.new()
	add_child(fade_timer)
	fade_timer.wait_time = 0.05
	fade_timer.one_shot = false
	fade_timer.connect("timeout", Callable(self, "_fade_out_effect"))
	fade_timer.start()

func _fade_out_effect():
	if wormhole_background == null or wormhole_background.material == null:
		print("Error: 'wormhole_background' or its material is null.")
		return
	
	# Gradually decrease intensity
	var intensity = wormhole_background.material.get_shader_parameter("intensity")
	if intensity == null:
		intensity = 0.0  # Initialize if null
	
	if intensity > 0.0:
		intensity -= 0.05
		intensity = clamp(intensity, 0.0, 1.0)
		wormhole_background.material.set_shader_parameter("intensity", intensity)
		print("Decreasing intensity to ", intensity)
	else:
		# Stop the fade-out and reset the background to black
		wormhole_background.material.set_shader_parameter("intensity", 0.0)
		fade_timer.stop()
		fade_timer.queue_free()
		print("Fade-out complete. Intensity reset to 0.0")
