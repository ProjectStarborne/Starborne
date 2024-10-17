class_name Inventory

const MAX_SLOTS = 16

var _content: Dictionary = {}
var size = 0

func add_item(item:Item) -> bool:
	if size == MAX_SLOTS:
			return false
	
	#if item.name in _content:
		## Increase the quantity if the item already exists in the inventory
		#_content[item.name].quantity += 1
	#else:
		## Add the new item with quantity 1
		#_content[item.name] = item
		#_content[item.name].quantity += 1
		#size += 1
	#
	#return true
	for i in range(MAX_SLOTS):
		if !_content.has(i):
			_content[i] = item
			size += 1
			return true
	
	return false
		
	
func remove_item(item:Item):
	#if item.name in _content:
		#_content[item.name].quantity -= 1
		#if _content[item.name].quantity <= 0:
			#_content.erase(item.name)
			#size -= 1
	for slot_index in _content.keys():
		if _content[slot_index] == item:
			if _content[slot_index].quantity > 1:
				_content[slot_index].quantity -= 1
			else:
				_content.erase(slot_index)
				size -= 1
			return
	
func get_items() -> Array[Item]:
	var items: Array[Item] = []
	for value in range(MAX_SLOTS):
		if _content.has(value):
			items.append(_content[value])
		else:
			items.append(null)
		
	return items

# Check if the item exists in the inventory
func has_item(item: Item) -> bool:
	return item.name in _content and _content[item.name].quantity > 0


func swap_items(slot_a : int, slot_b : int):
	#var items = get_items()
	#var temp = items[slot_a]
	#items[slot_a] = items[slot_b]
	#items[slot_b] = temp
	#
	## Update _content to reflect changes
	#var new_dict : Dictionary = {}
	#for item in items:
		#if item != null and has_item(item):
			#new_dict[item.name] = item
			#new_dict[item.name].quantity = _content[item.name].quantity
		#
	#_content = new_dict
	var item_a = _content.get(slot_a, null)
	var item_b = _content.get(slot_b, null)
	
	_content[slot_a] = item_b
	_content[slot_b] = item_a
