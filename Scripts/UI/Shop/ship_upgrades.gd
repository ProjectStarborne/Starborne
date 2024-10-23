extends Control

@onready var grid_container = $Control/VBoxContainer/ScrollContainer/GridContainer
@onready var click_sound = $KeyboardClick  # The AudioStreamPlayer node for the sound effect
@onready var player = get_node("%Player")  # Access the global player node

# Define the list of upgrades with their associated cost and purchase status
var upgrade_costs = {
	"Warp Engine V.1": 30,
	"Fuel Efficiency Module V.1": 50,
	"Stellar Cartography Module": 100,
	"Reinforced Hull Plating": 200,
	"Warp Engine V.2": 230,
	"Deep Space Scanners": 300,
	"Dark Matter Fuel Cells": 400
}


func _ready():
	populate_upgrade_buttons()

# Function to populate the UI with buy buttons and connect signals
func populate_upgrade_buttons():
	for i in range(grid_container.get_child_count()):
		var upgrade_box = grid_container.get_child(i) as HBoxContainer
		var vbox_container = upgrade_box.get_node("VBoxContainer") as VBoxContainer
		var upgrade_button = upgrade_box.get_node("BuyButton") as Button  # Adjusted to match your hierarchy
		var upgrade_label = vbox_container.get_node("Upgrade") as Label
		var cost_label = vbox_container.get_node("Cost") as Label

		if upgrade_button == null:
			print("Error: Buy button not found in ", upgrade_box.name)
			continue

		var upgrade_name = upgrade_label.text  # Read the upgrade name
		upgrade_button.set_meta("upgrade_name", upgrade_name)
		
		# Connect buy button signals for each upgrade
		var press_signal = Callable(self, "_on_buy_button_pressed")
		if upgrade_button.is_connected("pressed", press_signal):
			upgrade_button.disconnect("pressed", press_signal)
		upgrade_button.pressed.connect(press_signal.bind(upgrade_button))
		upgrade_button.connect("mouse_entered", Callable(self, "_on_upgrade_button_mouse_entered").bind(upgrade_button))
		upgrade_button.connect("mouse_exited", Callable(self, "_on_upgrade_button_mouse_exited").bind(upgrade_button))


# Handle buy button press logic
func _on_buy_button_pressed(upgrade_button: Button) -> void:
	var upgrade_name = upgrade_button.get_meta("upgrade_name")
	var upgrade_cost = upgrade_costs.get(upgrade_name, 0)

	# Use the global upgrades_purchased dictionary from Globals.gd
	if Globals.upgrades_purchased[upgrade_name]:
		display_popup_message(upgrade_name + " already purchased.")
		return

	if player.get_credits() >= upgrade_cost:
		player.remove_credits(upgrade_cost)
		Globals.upgrades_purchased[upgrade_name] = true  # Update the global dictionary
		display_popup_message(upgrade_name + " purchased successfully.")
	else:
		display_popup_message("Not enough credits to purchase " + upgrade_name)



# Handle mouse hover sound effects
func _on_upgrade_button_mouse_entered(upgrade_button: Button) -> void:
	click_sound.play()


func _on_upgrade_button_mouse_exited(upgrade_button: Button) -> void:
	pass


func _on_close_button_pressed() -> void:
	hide()


# Display a message in the popup label
func display_popup_message(message: String):
	var popup_label = $Control/BrokeAlert  # Adjust the path to the label
	popup_label.text = message
	popup_label.visible = true
	await get_tree().create_timer(2.0).timeout  # Show message for 2 seconds
	popup_label.visible = false
