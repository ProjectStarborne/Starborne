class_name Mineral extends Item

@export var mineral_type : String

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
		"type": "Mineral",  # Add the subclass identifier here
		"mineral_type": mineral_type
	}
	return dict

static func from_dict(data: Dictionary) -> Mineral:
	var mineral = Mineral.new()
	mineral.name = data["name"]
	
	if data.has("scene_path") and data["scene_path"] != "":
		mineral.scene = load(data["scene_path"])
	
	mineral.icon = load(data["icon"]) as Texture
	mineral.price = data["price"]
	mineral.weight = data["weight"]
	mineral.description = data["description"]
	mineral.stackable = data["stackable"]
	mineral.quantity = data["quantity"]
	mineral.consumable = data["consumable"]
	mineral.mineral_type = data["mineral_type"]
	
	return mineral
