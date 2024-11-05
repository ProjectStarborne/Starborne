extends PanelContainer

@onready var texture_rect = $TextureRect

@export var slot_num : int
@export var is_hotbar_slot : bool

signal item_swap(from_slot : int, to_slot : int, is_to_hotbar : bool, is_from_hotbar : bool)
signal storage_item_swap(from_slot : int, to_slot : int)
signal storage_swap(from_slot : int, to_slot : int, to_storage)

# Returns texture for dragging
func _get_drag_data(at_position: Vector2) -> Variant:
	print("Getting drop data")
	
	set_drag_preview(get_preview())
	
	#var drag_data = {
		#"texture": texture_rect.texture,
		#"slot_num": slot_num,
		#"is_hotbar_slot": is_hotbar_slot
	#}
	return texture_rect
	
# Check if the item is droppable or not
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	print("Checking drop data")
	return data is TextureRect
	
# Swap the texture data
func _drop_data(_pos: Vector2, data: Variant):
	var temp = texture_rect.texture
	
	# Swap textures
	texture_rect.texture = data.texture
	data.texture = temp
	
	var parent = data.get_parent()
	var to_slot = slot_num
	var from_slot = parent.slot_num
	if is_in_group("Storage Slot") and parent.is_in_group("Storage Inventory Slot"):
		# Emit signal to transfer item from inventory to storage
		emit_signal("storage_swap", from_slot, to_slot, true)
	elif is_in_group("Storage Inventory Slot") and parent.is_in_group("Storage Slot"):
		# Emit signal to transfer item from storage to inventory
		emit_signal("storage_swap", from_slot, to_slot, false)
	elif is_in_group("Storage Slot") and parent.is_in_group("Storage Slot"):
		emit_signal("storage_item_swap", from_slot, to_slot)
	else:
		# Emit signal to update inventory or hotbar
		var is_from_hotbar = parent.is_hotbar_slot
		emit_signal("item_swap", from_slot, to_slot, is_hotbar_slot, is_from_hotbar)
# Create drag and drop preview
# Gives indication that the item in the slot has been clicked
func get_preview():
	var preview_texture = TextureRect.new()
	
	# Set properties of preview (may make it so its slightly transparent)
	preview_texture.texture = texture_rect.texture
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(64, 64)
	preview_texture.z_index = 2
	
	# Bring to view
	var preview = Control.new()
	preview.add_child(preview_texture)
	
	return preview
