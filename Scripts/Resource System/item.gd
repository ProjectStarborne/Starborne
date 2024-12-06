class_name Item extends Resource

# If you need to create a new item, just go into res://data/items and create a new resource under this class.
@export var name : String
@export var scene : PackedScene
@export var type : String
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
		"scene_path" : scene.resource_path,
		"type" : type,
		"icon" : icon.resource_path,
		"price" : price,
		"weight" : weight,
		"description" : description,
		"stackable" : stackable,
		"quantity" : quantity,
		"consumable" : consumable,
	}

static func from_dict(data: Dictionary) -> Item:
	var item_type = data.get("type", "Item")	# Default to Item if no type is found

	var instance
	match item_type:
		"Tool":
			instance = Tool.new()
		"Mineral":
			instance = Mineral.new()
		"Usable":
			instance = Usable.new()
		_:
			instance = Item.new()
			instance.name = data["name"]
			
			if data.has("scene_path") and data["scene_path"] != "":
				instance.scene = load(data["scene_path"])	# load the scene as packed scene
			
			instance.type = data["type"]
			instance.icon = load(data["icon"]) as Texture
			instance.price = data["price"]
			instance.weight = data["weight"]
			instance.description = data["description"]
			instance.stackable = data["stackable"]
			instance.quantity = data["quantity"]
			instance.consumable = data["consumable"]
			
			return instance
			
	if instance:
		return instance.from_dict(data)
	else:
		print("Warning: Could not find class for type: ", item_type)
		return null
