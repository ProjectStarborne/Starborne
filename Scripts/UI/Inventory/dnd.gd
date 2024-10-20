extends PanelContainer

@onready var texture_rect = $TextureRect
@onready var label = $Label

@export var slot_num : int
@export var is_hotbar_slot : bool

signal item_swap(from_slot : int, to_slot : int, is_to_hotbar : bool, is_from_hotbar : bool)

# Returns texture for dragging
func _get_drag_data(at_position: Vector2) -> Variant:
	set_drag_preview(get_preview())
	
	#var drag_data = {
		#"texture": texture_rect.texture,
		#"slot_num": slot_num,
		#"is_hotbar_slot": is_hotbar_slot
	#}
	return texture_rect
	
# Check if the item is droppable or not
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is TextureRect
	
# Swap the texture data
func _drop_data(_pos: Vector2, data: Variant):
	var temp = texture_rect.texture
	var temp_text = label.text
	
	# Swap textures
	texture_rect.texture = data.texture
	data.texture = temp
	
	
	
	# Emit signal to update inventory or hotbar
	var parent = data.get_parent()
	var to_slot = slot_num
	var from_slot = parent.slot_num
	var is_from_hotbar = parent.is_hotbar_slot
	emit_signal("item_swap", from_slot, to_slot, is_hotbar_slot, is_from_hotbar)

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
