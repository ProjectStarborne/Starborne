extends Control

# Gives access to grid container manipulation
@onready var grid_container : GridContainer = %GridContainer
@onready var inv : Inventory
@onready var hotbar = %HotBar
@onready var credits_label: Label = %CreditsLabel

@onready var player = %Player


func open(inventory:Inventory):
	inv = inventory
	
	show()
	
	var slots = get_tree().get_nodes_in_group("Inventory Slot")
	#debug_inventory(inventory.get_items(), slots)
	
	var slot_num = 0
	# This is where the inventory will be populated with item icons
	for item in inventory.get_items():
		if slot_num != slots.size() - 1 and item:
			var image = item.icon
			var children = slots[slot_num].get_children()
			children[0].set_texture(image)
			# Update the stack labels to show the proper amount of items in inventory
		slot_num += 1

	credits_label.text = "Credits: " + str(player.credits)
func close():
	hide()

func _on_close_button_pressed() -> void:
	close()

# Connected to slot item swap signal
func _on_item_swap(from_slot : int, to_slot : int, is_to_hotbar : bool, is_from_hotbar : bool):
	print("Item swapping...", "From Hotbar: ", is_from_hotbar, " To Hotbar: ", is_to_hotbar)
	
	# Determine the type of swap and update inventory or hotbar
	if is_from_hotbar and is_to_hotbar:
		# Swapping between hotbar slots
		inv.swap_hotbar_items(from_slot, to_slot)
	elif is_from_hotbar and not is_to_hotbar:
		var hotbar_items = inv.get_hotbar_items()
		
		# Swapping from hotbar to inventory
		inv.add_item_to_slot(hotbar_items[from_slot], to_slot)
		inv.remove_from_hotbar(from_slot)
	elif not is_from_hotbar and is_to_hotbar:
		# Swapping from inventory to hotbar
		if !inv.add_to_hotbar(from_slot):
			print("Item not added to hotbar!")
		inv.remove_item(from_slot)
		
	else:
		# Swapping between inventory slots
		inv.swap_items(from_slot, to_slot)
		
	hotbar.update_hotbar_ui(inv)

# Check to make sure inventory is getting data
func debug_inventory(inventory : Array, slots : Array):
	var counter = 1
	for item in inventory:
		print(counter, ": ", item.name)
		counter += 1
