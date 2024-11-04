class_name Tool extends Item

@export var charge: float
@export var level : int

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
		"type": "Tool",  # Add the subclass identifier here
		"charge": charge,
		"level": level
	}
	return dict

static func from_dict(data: Dictionary) -> Tool:
	var tool = Tool.new()
	tool.name = data["name"]
	
	if data.has("scene_path") and data["scene_path"] != "":
		tool.scene = load(data["scene_path"])
	
	tool.icon = load(data["icon"]) as Texture
	tool.price = data["price"]
	tool.weight = data["weight"]
	tool.description = data["description"]
	tool.stackable = data["stackable"]
	tool.quantity = data["quantity"]
	tool.consumable = data["consumable"]
	tool.charge = data["charge"]
	tool.level = data["level"]
	
	return tool
