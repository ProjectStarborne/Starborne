class_name Mineral extends Item

@export var mineral_type : String

# Add tool-specific properties to the save dictionary
func to_dict() -> Dictionary:
	var dict = super.to_dict()
	dict["type"] = "Mineral"
	dict["mineral_type"] = mineral_type
	return dict

static func from_dict(data: Dictionary) -> Tool:
	var mineral = Mineral.new()
	mineral = super.from_dict(data)
	mineral.mineral_type = data["mineral_type"]
	return mineral
