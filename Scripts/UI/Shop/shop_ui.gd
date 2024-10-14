# shop.gd (Shop Logic)
extends Control

# Access the GridContainer where items will be displayed
@onready var grid_container = $ShopControl/VBoxContainer/ScrollContainer/GridContainer

# Shop inventory, this is separate from the player's inventory
var shop_inventory: Inventory = Inventory.new()
# Optionally, if you have a player's inventory for trading or purchasing
var player_inventory: Inventory = Inventory.new()  # Player's inventory (to handle trading)

# Trade requirements, e.g., 3 Iron for 1 Platinum, 2 Iron for 1 Iridium, etc.
var trade_requirements = {
	"Iron": { "Iron": 2 },    # Trade 1 Iron for 2 Iron
	"Platinum": { "Iron": 3 },  # Trade 3 Iron for 1 Platinum
	"Iridium": { "Iron": 2 },   # Trade 2 Iron for 1 Iridium
	"Nickel": { "Iron": 1 },    # Trade 1 Iron for 1 Nickel
}


func _ready():
	# Access the world scene
	var world = get_tree().current_scene
	#print("World scene: ", world)

	# Access the player node by its path or search for it in the scene tree
	var player = world.get_node_or_null("Player")  # Adjust "Player" if the actual path or name differs

	# If the player isn't a direct child, try using find_node()
	if player == null:
		player = world.find_node("Player", true, false)  # Replace "Player" with the actual player node name
		if player == null:
			print("Error: Player not found in the world scene!")
		else:
			print("Player found using find_node: ", player)
	else:
		print("Player found: ", player)

	# Now assign the player's inventory to player_inventory
	if player != null:
		player_inventory = player.inventory
		#print("Player inventory: ", player_inventory)
		
	# Initialize player with some test inventory items for the shop trade
	var iron_item_1 = load("res://Data/Items/Minerals/iron.tres") as Item
	var iron_item_2 = iron_item_1.duplicate()  # Create a duplicate of the first iron item
	player.inventory.add_item(iron_item_1)
	player.inventory.add_item(iron_item_2)


	
	# Manually add items to the shop inventory
	var iron_item = load("res://Data/Items/Minerals/iron.tres") as Item
	var iridium_item = load("res://Data/Items/Minerals/iridium.tres") as Item
	var platinum_item = load("res://Data/Items/Minerals/platinum.tres") as Item
	var nickel_item = load("res://Data/Items/Minerals/nickel.tres") as Item
	
	# Debug to check loaded items
	#print("Loaded Items: ", iron_item, iridium_item, platinum_item, nickel_item)

	# Add the items to the shop's inventory
	shop_inventory.add_item(iron_item)
	shop_inventory.add_item(iridium_item)
	shop_inventory.add_item(platinum_item)
	shop_inventory.add_item(nickel_item)
	
	#print("Items added to shop inventory: ", shop_inventory.get_items())

	# Populate the shop UI with these manually added items
	populate_shop(shop_inventory.get_items())


func populate_shop(items: Array[Item]):
	var slot_num = 0
	for item in items:
		if slot_num < grid_container.get_child_count():
			var item_box = grid_container.get_child(slot_num) as HBoxContainer

			# Set the item icon and name
			var texture_rect = item_box.get_node("Item " + str(slot_num + 1)) as TextureRect
			texture_rect.texture = item.icon
			print("TextureRect for Item ", item.name, " at slot ", slot_num, ": ", texture_rect)

			var description_vbox = item_box.get_node("DescriptionVBox" + str(slot_num + 1)) as VBoxContainer
			var item_name_label = description_vbox.get_node("ItemNameLabel") as Label
			var cost_label = description_vbox.get_node("CostLabel") as Label
			item_name_label.text = item.name
			
			# Set the cost label
			var cost_string = get_cost_string(item)
			cost_label.text = "Trade: " + cost_string

			# Set up the trade button
			var trade_button = item_box.get_node("TradeButton") as Button
			if trade_button != null:
				# Safely disconnect the pressed signal, if it was connected
				var callable_signal = Callable(self, "_on_trade_button_pressed_with_item")
				if trade_button.is_connected("pressed", callable_signal):
					trade_button.disconnect("pressed", callable_signal)

				# Reconnect the signal using the updated item
				trade_button.set_meta("item", item)
				trade_button.set_meta("animation_player", item_box.get_node("TradeButton/AnimationPlayer"))  # Set the AnimationPlayer metadata
				trade_button.pressed.connect(callable_signal.bind(item))
				
				# Connect the mouse_entered and mouse_exited signals manually
				trade_button.connect("mouse_entered", Callable(self, "_on_trade_button_mouse_entered").bind(trade_button))
				trade_button.connect("mouse_exited", Callable(self, "_on_trade_button_mouse_exited").bind(trade_button))

		slot_num += 1

	# Hide remaining slots if there are fewer items than slots
	for i in range(slot_num, grid_container.get_child_count()):
		var unused_item_box = grid_container.get_child(i) as HBoxContainer
		unused_item_box.visible = false



func _on_trade_button_pressed_with_item(item: Item) -> void:
	if player_can_trade(item):
		print("Traded for ", item.name)
		execute_trade(item)
		update_shop_ui()
		update_inventory_ui()
	else:
		#print("Not enough resources to trade for ", item.name)
		pass



func get_cost_string(item: Item) -> String:
	if trade_requirements.has(item.name):
		var requirements = trade_requirements[item.name]
		var cost_parts = []
		for key in requirements.keys():
			cost_parts.append(str(requirements[key]) + " " + key)
		return ", ".join(cost_parts)
	return "N/A"



# Check if the player can trade for the selected item
func player_can_trade(item: Item) -> bool:
	if trade_requirements.has(item.name):
		var required_items = trade_requirements[item.name]
		for required_item_name in required_items:
			var required_quantity = required_items[required_item_name]
			var found_quantity = 0

			# Check the player's inventory for the required item and its quantity
			if required_item_name in player_inventory._content:
				found_quantity = player_inventory._content[required_item_name].quantity
			
			if found_quantity < required_quantity:
				# Print the correct requirement for the current item
				print("Not enough ", required_item_name, " for trading ", item.name, ". Need: ", required_quantity, ", Have: ", found_quantity)
				return false
		# If the player has enough, return true
		return true
	return false




# Execute the trade
func execute_trade(item: Item):
	var required_items = trade_requirements[item.name]
	print("Executing trade for: ", item.name, " Requirements: ", required_items)  # Debugging print
	
	for required_item_name in required_items:
		var required_quantity = required_items[required_item_name]
		
		var remaining_quantity_to_remove = required_quantity
		for player_item in player_inventory.get_items():
			if player_item.name == required_item_name:
				if player_item.quantity >= remaining_quantity_to_remove:
					player_item.quantity -= remaining_quantity_to_remove
					remaining_quantity_to_remove = 0
				else:
					remaining_quantity_to_remove -= player_item.quantity
					player_item.quantity = 0

				if player_item.quantity <= 0:
					player_inventory.remove_item(player_item)

				if remaining_quantity_to_remove == 0:
					break

	player_inventory.add_item(item)
	print("Added ", item.name, " to player's inventory")
	
	shop_inventory.remove_item(item)
	
	# Refresh the UI after the trade
	update_shop_ui()
	
	# Refresh the player's inventory UI as well to reflect the changes
	update_inventory_ui()


func update_inventory_ui():
	if get_tree().current_scene.has_node("CanvasLayer/InventoryUI"):
		var inventory_ui = get_tree().current_scene.get_node("CanvasLayer/InventoryUI") as Control
		if inventory_ui and inventory_ui.visible:
			inventory_ui.open(player_inventory)  # Only refresh if the inventory is already open



# Update the shop UI (use this after an item is traded)
func update_shop_ui():
	populate_shop(shop_inventory.get_items())


# Function to close the shop when the close button is pressed
func _on_close_button_pressed():
	hide()


func _on_trade_button_mouse_entered(trade_button: Button) -> void:
	print("mouse entered!")
	var animation_player = trade_button.get_meta("animation_player") as AnimationPlayer
	if animation_player:
		animation_player.play("enlarge_on_hover")


func _on_trade_button_mouse_exited(trade_button: Button) -> void:
	print("mouse exited!")
	var animation_player = trade_button.get_meta("animation_player") as AnimationPlayer
	if animation_player:
		animation_player.play("shrink_on_exit")
