# shop.gd (Shop Logic)
extends Control

# Access the GridContainer where items will be displayed
@onready var grid_container = $ScrollContainer/GridContainer
# store the player node
var player 
# Shop inventory, this is separate from the player's inventory
var shop_inventory: Inventory = Inventory.new()
# Optionally, if you have a player's inventory for trading or purchasing
#var player_inventory: Inventory = Inventory.new()  # Player's inventory (to handle trading)
#var player_inventory  # Don't initialize with Inventory.new()
# Add all mineral names to the array so we know when to disable the buy button 
var mineral_names = ["Iron", "Iridium", "Platinum", "Nickel", "Hydrogen"] 


func _ready():
	# Access the world scene
	var world = get_tree().current_scene

	# Access the player node by its path or search for it in the scene tree
	player = world.get_node_or_null("Player")  # Adjust "Player" if the actual path or name differs

	# If the player isn't a direct child, try using find_node()
	if player == null:
		player = world.find_node("Player", true, false)  # Replace "Player" with the actual player node name
		if player == null:
			print("Error: Player not found in the world scene!")
		else:
			print("Player found using find_node: ", player)
	else:
		print("Player found: ", player)



	# Get the current level (we will need to adjust this to wherever we store the level info)
	var current_level = player.get_level()  # Call get_level() in player.gd
	
	# Get the shop items based on the current level
	var shop_items = get_shop_items_for_level(current_level)

	# Populate the shop inventory with these items
	for item in shop_items:
		shop_inventory.add_item(item)

	# Populate the shop UI with these manually added items
	populate_shop(shop_inventory.get_items())


func get_shop_items_for_level(level: int) -> Array[Item]:
	var items_for_level: Array[Item] = []

	# Define items for different levels
	items_for_level.append(load("res://Data/Items/Minerals/iron.tres") as Item)
	items_for_level.append(load("res://Data/Items/Minerals/nickel.tres") as Item)
	items_for_level.append(load("res://Data/Items/Consumables/duct_tape.tres") as Item)
	items_for_level.append(load("res://Data/Items/Consumables/oxygen_tank.tres") as Item)
	items_for_level.append(load("res://Data/Items/Consumables/medkit.tres") as Item)
	items_for_level.append(load("res://Data/Items/Tools/drill.tres") as Item)
	items_for_level.append(load("res://Data/Items/Minerals/iridium.tres") as Item)
	items_for_level.append(load("res://Data/Items/Minerals/platinum.tres") as Item)

	return items_for_level


func populate_shop(items: Array[Item]):
	var slot_num = 0
	for item in items:
		if item == null:
			#print("Warning: Null item found")
			continue  # Skip null items
			
		# Debug print to check if the item has a valid icon
		if item.icon == null:
			print("Warning: Item '" + item.name + "' has a null icon.")
		else:
			#print("Item '" + item.name + "' has a valid icon: ", item.icon)
			pass
			
		if slot_num < grid_container.get_child_count():
			var item_box = grid_container.get_child(slot_num) as HBoxContainer

			# Set the item icon and name
			var texture_rect = item_box.get_node_or_null("Item " + str(slot_num + 1)) as TextureRect
			if texture_rect != null:
				texture_rect.texture = item.icon
			else:
				print("Error: TextureRect 'Item " + str(slot_num + 1) + "' not found in slot ", slot_num)

			var description_vbox = item_box.get_node_or_null("DescriptionVBox" + str(slot_num + 1)) as VBoxContainer
			if description_vbox != null:
				var item_name_label = description_vbox.get_node_or_null("ItemNameLabel") as Label
				var cost_label = description_vbox.get_node_or_null("CostLabel") as Label
				
				if item_name_label != null:
					item_name_label.text = item.name
				else:
					print("Error: 'ItemNameLabel' not found in DescriptionVBox" + str(slot_num + 1))
				
				if cost_label != null:
					cost_label.text = "Price: " + str(item.price) + " credits"
				else:
					print("Error: 'CostLabel' not found in DescriptionVBox" + str(slot_num + 1))
			else:
				print("Error: DescriptionVBox" + str(slot_num + 1) + " not found in slot ", slot_num)
				continue  # Skip setting up buttons if DescriptionVBox is missing

			# Set up the buy button
			var buy_button = item_box.get_node_or_null("BuyButton") as Button
			if buy_button != null:
				# Disable the button if the item is a mineral
				if item.name in mineral_names:
					buy_button.disabled = true
				else:
					buy_button.disabled = false  # Ensure it's enabled for non-minerals
				
				# Safely disconnect the pressed signal, if it was connected
				var buy_signal = Callable(self, "_on_buy_button_pressed_with_item")
				if buy_button.is_connected("pressed", buy_signal):
					buy_button.disconnect("pressed", buy_signal)

				# Reconnect the signal using the updated item
				buy_button.set_meta("item", item)
				buy_button.set_meta("animation_player", item_box.get_node("BuyButton/AnimationPlayer"))  # Set the AnimationPlayer metadata
				buy_button.pressed.connect(buy_signal.bind(item))

				# Connect the mouse_entered and mouse_exited signals manually for buy button
				buy_button.connect("mouse_entered", Callable(self, "_on_buy_button_mouse_entered").bind(buy_button))
				buy_button.connect("mouse_exited", Callable(self, "_on_buy_button_mouse_exited").bind(buy_button))
			else:
				print("Error: 'BuyButton' not found in slot ", slot_num)

			# Set up the sell button
			var sell_button = item_box.get_node_or_null("SellButton") as Button
			if sell_button != null:
				# Safely disconnect the pressed signal, if it was connected
				var sell_signal = Callable(self, "_on_sell_button_pressed_with_item")
				if sell_button.is_connected("pressed", sell_signal):
					sell_button.disconnect("pressed", sell_signal)

				# Reconnect the signal using the updated item
				sell_button.set_meta("item", item)
				sell_button.set_meta("animation_player", item_box.get_node("SellButton/AnimationPlayer"))  # Set the AnimationPlayer metadata
				sell_button.pressed.connect(sell_signal.bind(item))

				# Connect the mouse_entered and mouse_exited signals manually for sell button
				sell_button.connect("mouse_entered", Callable(self, "_on_sell_button_mouse_entered").bind(sell_button))
				sell_button.connect("mouse_exited", Callable(self, "_on_sell_button_mouse_exited").bind(sell_button))
			else:
				print("Error: 'SellButton' not found in slot ", slot_num)

		else:
			print("Warning: slot_num ", slot_num, " exceeds grid_container child count ", grid_container.get_child_count())
			break  # Exit the loop if there are more items than slots

		slot_num += 1

	# Hide remaining slots if there are fewer items than slots
	for i in range(slot_num, grid_container.get_child_count()):
		var unused_item_box = grid_container.get_child(i) as HBoxContainer
		if unused_item_box != null:
			unused_item_box.visible = false
		else:
			print("Error: Unused item box at index ", i, " is null")



# Handle buy logic when the buy button is pressed
func _on_buy_button_pressed_with_item(item: Item) -> void:
	if player_can_afford(item):
		print("Purchased ", item.name, " for ", item.price, " credits")
		display_popup_message(item.name + " purchased!")
		execute_purchase(item)
		update_shop_ui()
		update_inventory_ui()
	else:
		print("Not enough credits to purchase ", item.name)
		display_popup_message("Not enough credits to buy " + item.name)


# Handle sell logic when the sell button is pressed
func _on_sell_button_pressed_with_item(item: Item) -> void:
	if player.inventory.has_item(item):
		print("Sold ", item.name, " for ", item.price, " credits")
		display_popup_message(item.name + " sold!")
		execute_sale(item)
		update_shop_ui()
		update_inventory_ui()
	else:
		print("You do not have ", item.name, " to sell")
		display_popup_message("You do not have " + item.name + " to sell")



# Check if the player can afford the selected item
func player_can_afford(item: Item) -> bool:
	return Globals.get_credits() >= item.price


# Execute the purchase
func execute_purchase(item: Item):
	# Deduct the price from the player's credits
	Globals.remove_credits(item.price)

	# Add the item to the player's inventory directly
	player.inventory.add_item(item)
	print("Added ", item.name, " to player's inventory")

	# Refresh the shop UI and player's inventory UI
	update_shop_ui()
	update_inventory_ui()
	
	print("Credits: ", Globals.get_credits())




# Execute the sale
func execute_sale(item: Item):
	print("Executing sale for item: ", item.name)
	
	# Add the price to the player's credits (gain credits)
	Globals.add_credits(item.price)
	
	print("Credits after sale: ", Globals.get_credits())
	
	# Find the first item in the player's inventory with the same name
	var index = find_item_index_in_inventory(item.name)
	
	if index != -1:
		# Remove the item from the player's inventory by index
		player.inventory.remove_item(index)
		print("Removed ", item.name, " from player's inventory")
	else:
		print("Error: Item ", item.name, " not found in player's inventory")
	
	# Add the item to the shop's inventory (optional, depending on your logic)
	#shop_inventory.add_item(item)
	#print("Added ", item.name, " to shop inventory")
	
	# Refresh the shop UI and player's inventory UI
	update_shop_ui()
	update_inventory_ui()
	
	# Debug print to show current inventory
	print("Current Inventory:")
	for i in range(player.inventory.get_items().size()):
		var inv_item = player.inventory.get_items()[i]
		if inv_item != null:
			print("Slot ", i, ": ", inv_item.name)
		else:
			print("Slot ", i, ": Empty")
	
	print("Credits: ", Globals.get_credits())



# Helper function to find item index by name
func find_item_index_in_inventory(item_name: String) -> int:
	var items = player.inventory.get_items()
	for i in items.size():
		if items[i] != null and items[i].name == item_name:
			return i
	return -1



# Display a message in the popup label
func display_popup_message(message: String):
	var popup_label = $"../../BrokeAlert"  # Adjust the path to the label
	popup_label.text = message
	popup_label.visible = true
	await get_tree().create_timer(2.0).timeout  # Show message for 2 seconds
	popup_label.visible = false


func update_inventory_ui():
	if get_tree().current_scene.has_node("CanvasLayer/InventoryUI"):
		var inventory_ui = get_tree().current_scene.get_node("CanvasLayer/InventoryUI") as Control
		if inventory_ui and inventory_ui.visible:
			inventory_ui.open(player.inventory)  # Only refresh if the inventory is already open


# Update the shop UI (use this after an item is traded)
func update_shop_ui():
	populate_shop(shop_inventory.get_items())



# Function to close the shop when the close button is pressed
#func _on_close_button_pressed():
#	hide()

# Mouse enter/exit handlers for buy button
func _on_buy_button_mouse_entered(buy_button: Button) -> void:
	if buy_button.disabled:
		return  # Do nothing if the button is disabled

	var animation_player = buy_button.get_meta("animation_player") as AnimationPlayer
	if animation_player:
		animation_player.play("enlarge_on_hover")


func _on_buy_button_mouse_exited(buy_button: Button) -> void:
	if buy_button.disabled:
		return  # Do nothing if the button is disabled
	var animation_player = buy_button.get_meta("animation_player") as AnimationPlayer
	if animation_player:
		animation_player.play("shrink_on_exit")


# Mouse enter/exit handlers for sell button
func _on_sell_button_mouse_entered(sell_button: Button) -> void:
	if sell_button.disabled:
		return  # Do nothing if the button is disabled
	var animation_player = sell_button.get_meta("animation_player") as AnimationPlayer
	if animation_player:
		animation_player.play("enlarge_on_hover")


func _on_sell_button_mouse_exited(sell_button: Button) -> void:
	if sell_button.disabled:
		return  # Do nothing if the button is disabled
	var animation_player = sell_button.get_meta("animation_player") as AnimationPlayer
	if animation_player:
		animation_player.play("shrink_on_exit")


func _on_close_button_pressed() -> void:
	hide() 
