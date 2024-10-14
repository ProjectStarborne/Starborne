class_name Inventory

var _content: Dictionary = {}

func add_item(item:Item):
	if item.name in _content:
		# Increase the quantity if the item already exists in the inventory
		_content[item.name].quantity += 1
	else:
		# Add the new item with quantity 1
		_content[item.name] = item
		_content[item.name].quantity += 1
	
func remove_item(item:Item):
	if item.name in _content:
		_content[item.name].quantity -= 1
		if _content[item.name].quantity <= 0:
			_content.erase(item.name)
	
func get_items() -> Array[Item]:
	var items: Array[Item] = []
	for value in _content.values():
		items.append(value as Item)
	return items
