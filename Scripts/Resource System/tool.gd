class_name Tool extends Item

@export var charge: float
@export var level : int

# Add tool-specific properties to the save dictionary
func to_dict() -> Dictionary:
	var dict = super.to_dict()
	dict["type"] = "Tool"
	dict["charge"] = charge
	dict["level"] = level
	return dict

static func from_dict(data: Dictionary) -> Tool:
	var tool = Tool.new()
	tool = super.from_dict(data)
	tool.charge = data["charge"]
	tool.level = data["level"]
	return tool
