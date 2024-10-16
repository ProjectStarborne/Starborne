class_name Inventory

const MAX_SLOTS = 16

var _content: Dictionary = {}
var size = 0

func add_item(item:Item) -> bool:
	if item.name in _content:
		# Increase the quantity if the item already exists in the inventory
		_content[item.name].quantity += 1
	else:
		# Add the new item with quantity 1
		_content[item.name] = item
		_content[item.name].quantity += 1
		if size == MAX_SLOTS:
			return false
		size += 1
	
	return true
		
	
func remove_item(item:Item):
	if item.name in _content:
		_content[item.name].quantity -= 1
		if _content[item.name].quantity <= 0:
			_content.erase(item.name)
			size -= 1
	
func get_items() -> Array[Item]:
	var items: Array[Item] = []
	for value in _content.values():
		items.append(value as Item)
	return items

# Check if the item exists in the inventory
func has_item(item: Item) -> bool:
	return item.name in _content and _content[item.name].quantity > 0
