class_name Inventory

const MAX_SLOTS = 16
const HOTBAR_SLOTS = 3

var _content: Dictionary = {}
var _hotbar: Dictionary = {}
var size = 0

func _init():
	# Initialize _content with null values for all slots
	# TODO: make a function for this and inventory population
	for i in range(MAX_SLOTS):
		if not _content.has(i):
			_content[i] = null
	
	for i in range(HOTBAR_SLOTS):
		if not _hotbar.has(i):
			_hotbar[i] = null
			

func add_item(item:Item) -> bool:
	if size == MAX_SLOTS:
			return false
	
	for i in range(MAX_SLOTS):
		if _content[i] == null or !_content.has(i):
			_content[i] = item
			_content[i].quantity += 1
			size += 1
			return true
	
	return false
		

func add_item_to_slot(item:Item, slot_index : int):
	_content[slot_index] = item
	size += 1

func remove_item(index : int):
	if _content[index] != null:
		_content[index] = null
		size -= 1
	
# Get inventory items in the form of an array
func get_items() -> Array[Item]:
	var items: Array[Item] = []
	for value in range(MAX_SLOTS):
		if _content.has(value):
			items.append(_content[value])
		else:
			items.append(null)
		
	return items

# Get hotbar items in the form of an array
func get_hotbar_items() -> Array[Item]:
	var hotbar_items: Array[Item] = []
	for i in range(HOTBAR_SLOTS):
		hotbar_items.append(_hotbar[i])
	return hotbar_items
	


func add_to_hotbar(slot_index: int) -> bool:
	if _content.has(slot_index):
		# Find the first available hotbar slot
		for i in range(HOTBAR_SLOTS):
			if _hotbar[i] == null or !_hotbar.has(i):
				_hotbar[i] = _content[slot_index]
				return true
	return false
	
func remove_from_hotbar(hotbar_index: int):
	if _hotbar.has(hotbar_index):
		_hotbar.erase(hotbar_index)


# Check if the item exists in the inventory
func has_item(item: Item) -> bool:
	for inv_item in _content.values():
		if inv_item != null and inv_item.name == item.name:
			return true
	return false
	
	
func swap_items(slot_a : int, slot_b : int):
	var item_a = _content.get(slot_a, null)
	var item_b = _content.get(slot_b, null)
	
	_content[slot_a] = item_b
	_content[slot_b] = item_a

func swap_hotbar_items(hotbar_index: int, inventory_index: int):
	# Perform the swap between hotbar and inventory
	var hotbar_item = _hotbar.get(hotbar_index, null)
	var inventory_item = _content.get(inventory_index, null)
	
	_hotbar[hotbar_index] = inventory_item
	_content[inventory_index] = hotbar_item
