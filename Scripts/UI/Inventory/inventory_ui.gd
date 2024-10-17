extends Control

# Gives access to grid container manipulation
@onready var grid_container : GridContainer = %GridContainer
@onready var inv : Inventory

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
			if item.quantity > 1:
				children[1].text = str(item.quantity)
		slot_num += 1

func close():
	hide()

func _on_close_button_pressed() -> void:
	close()

# Connected to slot item swap signal
func _on_item_swap(from_slot : int, to_slot : int, is_to_hotbar : bool):
	# Swap items in the inventory
	if not is_to_hotbar:
		inv.swap_items(from_slot, to_slot)
	else:
		# Handle hotbar logic here
		pass

# Check to make sure inventory is getting data
func debug_inventory(inventory : Array, slots : Array):
	var counter = 1
	for item in inventory:
		print(counter, ": ", item.name)
		counter += 1
