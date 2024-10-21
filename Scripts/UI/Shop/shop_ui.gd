# shop.gd (Shop Logic)
extends Control

# Access the GridContainer where items will be displayed
@onready var grid_container = $ShopControl/VBoxContainer/ScrollContainer/GridContainer
# store the player node
var player 
# Shop inventory, this is separate from the player's inventory
var shop_inventory: Inventory = Inventory.new()
# Optionally, if you have a player's inventory for trading or purchasing
var player_inventory: Inventory = Inventory.new()  # Player's inventory (to handle trading)
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

	# Now assign the player's inventory to player_inventory
	if player != null:
		player_inventory = player.inventory

	# Initialize player with some test inventory items for the shop trade
	var iron_item_1 = load("res://Data/Items/Minerals/iron.tres") as Item
	var iron_item_2 = iron_item_1.duplicate()  # Create a duplicate of the first iron item
	player.inventory.add_item(iron_item_1)
	player.inventory.add_item(iron_item_2)

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
	if level == 1 or level == 2:
		# Load items for levels 1-2
		items_for_level.append(load("res://Data/Items/Minerals/iron.tres") as Item)
		items_for_level.append(load("res://Data/Items/Minerals/nickel.tres") as Item)
	elif level == 3 or level == 4:
		# Load items for levels 3-4
		items_for_level.append(load("res://Data/Items/Minerals/platinum.tres") as Item)
		items_for_level.append(load("res://Data/Items/Minerals/iridium.tres") as Item)
		items_for_level.append(load("res://Data/Items/Minerals/oxygen.tres") as Item)
	else:
		# Fallback for other levels or general items
		items_for_level.append(load("res://Data/Items/Minerals/iron.tres") as Item)
		items_for_level.append(load("res://Data/Items/Minerals/iridium.tres") as Item)
		items_for_level.append(load("res://Data/Items/Minerals/nickel.tres") as Item)
		items_for_level.append(load("res://Data/Items/Minerals/platinum.tres") as Item)

	return items_for_level


func populate_shop(items: Array[Item]):
	var slot_num = 0
	for item in items:
		if item == null:
			print("Warning: Null item found")
			continue  # Skip null items
			
		# Debug print to check if the item has a valid icon
		if item.icon == null:
			print("Warning: Item '" + item.name + "' has a null icon.")
		else:
			print("Item '" + item.name + "' has a valid icon: ", item.icon)
			
		if slot_num < grid_container.get_child_count():
			var item_box = grid_container.get_child(slot_num) as HBoxContainer

			# Set the item icon and name
			var texture_rect = item_box.get_node("Item " + str(slot_num + 1)) as TextureRect
			texture_rect.texture = item.icon

			var description_vbox = item_box.get_node("DescriptionVBox" + str(slot_num + 1)) as VBoxContainer
			var item_name_label = description_vbox.get_node("ItemNameLabel") as Label
			var cost_label = description_vbox.get_node("CostLabel") as Label
			item_name_label.text = item.name

			# Set the cost label from the item's price in the .tres file
			cost_label.text = "Price: " + str(item.price) + " credits"

			# Set up the buy button
			var buy_button = item_box.get_node("BuyButton") as Button
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

			# Set up the sell button
			var sell_button = item_box.get_node("SellButton") as Button
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

		slot_num += 1

	# Hide remaining slots if there are fewer items than slots
	for i in range(slot_num, grid_container.get_child_count()):
		var unused_item_box = grid_container.get_child(i) as HBoxContainer
		unused_item_box.visible = false


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
	if player_inventory.has_item(item):
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
	return player.credits >= item.price


# Execute the purchase
func execute_purchase(item: Item):
	# Deduct the price from the player's credits
	player.remove_credits(item.price)

	# Add the item to the player's inventory
	player_inventory.add_item(item)
	print("Added ", item.name, " to player's inventory")

	# Find the item's index in the shop inventory
	var index = shop_inventory.get_items().find(item)

	if index != -1:
		# Remove the item from the shop inventory by index
		shop_inventory.remove_item(index)

	# Refresh the shop UI and player's inventory UI
	update_shop_ui()
	update_inventory_ui()
	
	print("Credits: ", player.get_credits())




# Execute the sale
func execute_sale(item: Item):
	# Add the price to the player's credits (gain credits)
	player.add_credits(item.price)

	# Find the item's index in the player's inventory
	var index = player_inventory.get_items().find(item)

	if index != -1:
		# Remove the item from the player's inventory by index
		player_inventory.remove_item(index)
		print("Removed ", item.name, " from player's inventory")

	# Add the item to the shop's inventory (optional, depending on your logic)
	shop_inventory.add_item(item)

	# Refresh the shop UI and player's inventory UI
	update_shop_ui()
	update_inventory_ui()
	
	print("Credits: ", player.get_credits())



# Display a message in the popup label
func display_popup_message(message: String):
	var popup_label = $ShopControl/BrokeAlert  # Adjust the path to the label
	popup_label.text = message
	popup_label.visible = true
	await get_tree().create_timer(2.0).timeout  # Show message for 2 seconds
	popup_label.visible = false


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
