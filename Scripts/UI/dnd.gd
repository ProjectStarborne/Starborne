extends PanelContainer

@onready var texture_rect = $TextureRect
@onready var label = $Label

@export var slot_num : int
@export var is_hotbar_slot : bool

signal item_swap(slot_num : int)

# Returns texture for dragging
func _get_drag_data(at_position: Vector2) -> Variant:
	set_drag_preview(get_preview())
	
	return texture_rect
	
# Check if the item is droppable or not
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is TextureRect
	
# Swap the texture data
func _drop_data(_pos: Vector2, data: Variant):
	var temp = texture_rect.texture
	var temp_text = label.text
	texture_rect.texture = data.texture
	data.texture = temp
	
	# Swap quantity label texts
	var parent = data.get_parent()	
	label.text = parent.label.text
	parent.label.text = temp_text

# Create drag and drop preview
# Gives indication that the item in the slot has been clicked
func get_preview():
	var preview_texture = TextureRect.new()
	
	# Set properties of preview (may make it so its slightly transparent)
	preview_texture.texture = texture_rect.texture
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(30, 30)
	
	# Bring to view
	var preview = Control.new()
	preview.add_child(preview_texture)
	
	return preview
