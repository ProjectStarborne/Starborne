extends Control

# Gives access to grid container manipulation
@onready var grid_container : GridContainer = %GridContainer

func open(inventory: Inventory):
	show()
	
	var slots = get_tree().get_nodes_in_group("Inventory Slot")
	
	# Clear all the slots before repopulating
	for slot in slots:
		var texture = slot.get_children()
		texture[0].set_texture(null)  # Clear the slot
	
	debug_inventory(inventory.get_items(), slots)
	
	var slot_num = 0
	# Populate the inventory UI with item icons
	for item in inventory.get_items():
		for i in range(item.quantity):  # Display multiple icons based on quantity
			if slot_num < slots.size():
				var image = item.icon
				var texture = slots[slot_num].get_children()
				texture[0].set_texture(image)
				slot_num += 1
			else:
				break  # Stop if no more slots are available



func _on_close_button_pressed() -> void:
	hide()

# Check to make sure inventory is getting data
func debug_inventory(inventory : Array, slots : Array):
	var counter = 1
	for item in inventory:
		#print(counter, ": ", item.name)
		counter += 1
	
	for slot in slots:
		print(slot)
