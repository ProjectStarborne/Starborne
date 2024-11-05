class_name Usable extends Item

@export var effect : float

# Add tool-specific properties to the save dictionary
func to_dict() -> Dictionary:
	var dict = {
		"name": name,
		"scene_path": scene.resource_path,
		"icon" : icon.resource_path,
		"price": price,
		"weight": weight,
		"description": description,
		"stackable": stackable,
		"quantity": quantity,
		"consumable": consumable,
		"type": "Usable",  # Add the subclass identifier here
		"effect": effect
	}
	return dict

static func from_dict(data: Dictionary) -> Usable:
	var usable = Tool.new()
	usable.name = data["name"]
	
	if data.has("scene_path") and data["scene_path"] != "":
		usable.scene = load(data["scene_path"])
	
	usable.icon = load(data["icon"]) as Texture
	usable.price = data["price"]
	usable.weight = data["weight"]
	usable.description = data["description"]
	usable.stackable = data["stackable"]
	usable.quantity = data["quantity"]
	usable.consumable = data["consumable"]
	usable.effect = data["effect"]
	
	return usable
