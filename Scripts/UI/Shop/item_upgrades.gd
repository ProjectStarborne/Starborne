# shop.gd (Shop Logic)
extends Control

# Access the GridContainer where items will be displayed
@onready var grid_container = $ScrollContainer/GridContainer
# store the player node
var player 
# Shop inventory, this is separate from the player's inventory
var upgrade_inventory: Inventory = Inventory.new()


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

	
	# Get the shop items based on the current level
	var shop_items = get_shop_items_for_level()

	# Populate the shop inventory with these items
	for item in shop_items:
		upgrade_inventory.add_item(item)

	# Populate the shop UI with these manually added items
	populate_shop(upgrade_inventory.get_items())


func get_shop_items_for_level() -> Array[Item]:
	var items_for_level: Array[Item] = []
	items_for_level.append(load("res://Data/Items/Tools/drill.tres") as Item)
	items_for_level.append(load("res://Data/Items/Tools/flashlight.tres") as Item)
	items_for_level.append(load("res://Data/Items/Consumables/medkit.tres") as Item)
	items_for_level.append(load("res://Data/Items/Consumables/oxygen_tank.tres") as Item)

	return items_for_level



func populate_shop(items: Array[Item]):
	var slot_num = 0
	for item in items:
		if item == null:
			# print("Warning: Null item found")
			continue  # Skip null items
			
		# Debug print to check if the item has a valid icon
		if item.icon == null:
			print("Warning: Item '" + item.name + "' has a null icon.")
		else:
			# print("Item '" + item.name + "' has a valid icon: ", item.icon)
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
					cost_label.text = "Price: " + str(item.upgrade_price) + " credits"
				else:
					print("Error: 'CostLabel' not found in DescriptionVBox" + str(slot_num + 1))
			else:
				print("Error: DescriptionVBox" + str(slot_num + 1) + " not found in slot ", slot_num)
				continue  # Skip setting up buttons if DescriptionVBox is missing

			# Set up the buy button
			var buy_button = item_box.get_node_or_null("BuyButton") as Button
			if buy_button != null:
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
	if not player.inventory.has_item(item):
		print("You need to own ", item.name, " to upgrade it!")
		display_popup_message("You need to own " + item.name + " to upgrade!")
		return
		
	if player_can_afford(item):
		print("Purchased ", item.name, " for ", item.price, " credits")
		display_popup_message(item.name + " Upgraded!")
		execute_upgrade(item)
		update_shop_ui()
		update_inventory_ui()
	else:
		print("Not enough credits to purchase ", item.name)
		display_popup_message("Not enough credits to buy " + item.name)



# Check if the player can afford the selected item
func player_can_afford(item: Item) -> bool:
	return Globals.get_credits() >= item.price


# Execute the purchase
func execute_upgrade(item: Item):
	# Deduct the price from the player's credits
	Globals.remove_credits(item.price)
	
	# BRANDONS CODE GOES HERE
	if item.name == "Drill":
		var level = player.inventory.update_drill_level()
		
		if level == -1:
			print("Could not find Drill!")
		else:
			print("Drill upgraded to level " + str(level))
	elif item is Usable:
		match item.name:
			"Oxygen Tank":
				Globals.oxygen_modifier += 2.5
			"Medkit":
				Globals.medkit_modifier += 2.5 

	update_shop_ui() #useless code here, probably. 
	update_inventory_ui()
	
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
	populate_shop(upgrade_inventory.get_items())


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
