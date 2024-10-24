class_name Item extends Resource

# If you need to create a new item, just go into res://data/items and create a new resource under this class.
@export var name : String
@export var scene : PackedScene
@export var icon : Texture
@export var price : int
@export var weight : int
@export var description : String
@export var stackable : bool
@export var quantity : int
@export var consumable : bool

func to_dict() -> Dictionary:
	return {
		"name" : name,
		"price" : price,
		"weight" : weight,
		"description" : description,
		"stackable" : stackable,
		"quantity" : quantity,
		"consumable" : consumable
	}

static func from_dict(data: Dictionary) -> Item:
	var item_type = data.get("type", "Item")	# Default to Item if no type is found
	
	match item_type:
		"Tool":
			return Tool.from_dict(data)
		"Mineral":
			return Mineral.from_dict(data)
		_:
			var item = Item.new()
			item.name = data["name"]
			item.price = data["price"]
			item.weight = data["weight"]
			item.description = data["description"]
			item.stackable = data["stackable"]
			item.quantity = data["quantity"]
			item.consumable = data["consumable"]
			return item
