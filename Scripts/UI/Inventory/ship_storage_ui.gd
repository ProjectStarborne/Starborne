extends Control

# Gives access to both grid containers
@onready var inventory_grid_container: GridContainer = %InventoryGridContainer
@onready var ship_grid_container: GridContainer = %ShipGridContainer

# Player's inventory
@onready var inv : Inventory
@onready var ship_inv : Inventory

# Open ship storage UI and populate the grid container slots for both sides
func open(inventory : Inventory, storage : Inventory):
	inv = inventory
	ship_inv = storage
	
	populate("Storage Inventory Slot", inv)
	populate("Storage Slot", ship_inv)
	
	show()

# Populate a slot group with their respective items
func populate(group : String, inventory : Inventory):
	var slots = get_tree().get_nodes_in_group(group)
	#debug_inventory(inventory.get_items(), slots)
	var slot_num = 0
	# This is where the inventory will be populated with item icons
	for item in inventory.get_items():
		var children = slots[slot_num].get_children()
		
		if slot_num != slots.size() - 1 and item != null:
			var image = item.icon
			children[0].set_texture(image)
		else:
			children[0].set_texture(null)
			
		slot_num += 1
	
func close():
	hide()

# Close the UI
func _on_close_button_pressed() -> void:
	close()

# Transfer items to storage
func _on_transfer_to_storage_pressed() -> void:
	var list = inv.get_items()
	for i in range(list.size()):
		ship_inv.add_item(list[i])
		inv.remove_item(i)
	
	save()
	open(inv, ship_inv)

# Transfer items to inventory
func _on_transfer_to_inventory_pressed() -> void:
	var list = ship_inv.get_items()
	for i in range(list.size()):
		inv.add_item(list[i])
		ship_inv.remove_item(i)
	
	save()
	open(inv, ship_inv)


func _on_storage_swap(from_slot: int, to_slot: int, to_storage : bool) -> void:
	print("Item swapping...from storage? ", to_storage)
	
	if to_storage:
		var list = inv.get_items()
		ship_inv.add_item_to_slot(list[from_slot], to_slot)
		inv.remove_item(from_slot)
	else:
		var list = ship_inv.get_items()
		inv.add_item_to_slot(list[from_slot], to_slot)
		ship_inv.remove_item(from_slot)
	
	save()
	open(inv, ship_inv)

func save():
	Globals.inventory = inv
	Globals.ship_inventory = ship_inv
	


func _on_storage_item_swap(from_slot: int, to_slot: int) -> void:
	ship_inv.swap_items(from_slot, to_slot)
