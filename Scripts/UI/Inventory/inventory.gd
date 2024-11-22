## @Author: Brandon Grunes

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
			

# Add an item into _content
func add_item(item:Item) -> bool:
	if size == MAX_SLOTS or !item:
			return false
	
	# Determine quantity of item if already exists
	for i in range(MAX_SLOTS):
		if _content[i] == null or !_content.has(i):
			_content[i] = item
			_content[i].quantity += 1
			size += 1
			return true
	
	return false
		

# Add item to a specified index in _content
func add_item_to_slot(item:Item, slot_index : int):
	_content[slot_index] = item
	size += 1

# Remove item in _content by index
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
	

# Add item from _content to _hotbar by index. Used for when dragging and dropping items into slots
func add_to_hotbar(slot_index: int, hotbar_index : int) -> bool:
	if _content.has(slot_index):
		# Find the first available hotbar slot
		if _hotbar[hotbar_index] == null or !_hotbar.has(hotbar_index):
			_hotbar[hotbar_index] = _content[slot_index]
			return true
	return false
	
	
# Remove item from _hotbar by index
func remove_from_hotbar(hotbar_index: int):
	if _hotbar[hotbar_index] != null:
		_hotbar[hotbar_index] = null


# Check if the item exists in the inventory
func has_item(item: Item) -> bool:
	for inv_item in _content.values():
		if inv_item != null and inv_item.name == item.name:
			return true
	return false
	
	
# Swap items in specified slots
func swap_items(slot_a : int, slot_b : int):
	var item_a = _content.get(slot_a, null)
	var item_b = _content.get(slot_b, null)
	
	_content[slot_a] = item_b
	_content[slot_b] = item_a

#
func swap_hotbar_items(from_index: int, to_index: int):
	# Perform the swap between hotbar and inventory
	var temp = _hotbar[from_index]
	
	_hotbar[from_index] = _hotbar[to_index]
	_hotbar[to_index] = temp


func update_drill_level() -> int:
	for key in _content.keys():
		if _content[key] != null:
			if _content[key].name == "Drill":
				_content[key].level += 1
				return _content[key].level
	for key in _hotbar.keys():
		if _hotbar[key] != null:
			if _hotbar[key].name == "Drill":
				_hotbar[key].level += 1
				return _hotbar[key].level
	return -1

func to_dict() -> Dictionary:
	var content_dict = {}
	for key in _content.keys():
		var int_key = int(key)
		if _content[int_key] != null:
			content_dict[int_key] = _content[int_key].to_dict()
		else:
			content_dict[int_key] = null

	var hotbar_dict = {}
	for key in _hotbar.keys():
		var int_key = int(key)
		if _hotbar[int_key] != null:
			hotbar_dict[int_key] = _hotbar[int_key].to_dict()
		else:
			hotbar_dict[int_key] = null

	return {
		"content": content_dict,
		"hotbar": hotbar_dict,
		"size": size
	}

static func from_dict(data: Dictionary) -> Inventory:
	var inventory = Inventory.new()
	for key in data["content"].keys():
		var int_key = int(key)
		if data["content"][key] != null:
			inventory._content[int_key] = Item.from_dict(data["content"][key])
		else:
			inventory._content[int_key] = null
	
	if data.has("hotbar"):
		for key in data["hotbar"].keys():
			var int_key = int(key)
			if data["hotbar"][key] != null:
				inventory._hotbar[int_key] = Item.from_dict(data["hotbar"][key])
			else:
				inventory._hotbar[int_key] = null
	
	inventory.size = data["size"]
	return inventory
			
			
			
