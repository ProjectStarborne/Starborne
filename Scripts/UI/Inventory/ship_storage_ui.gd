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
	
	populate("Inventory Slot", inv)
	populate("Storage Slot", ship_inv)
	
	show()

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


func _on_close_button_pressed() -> void:
	close()
