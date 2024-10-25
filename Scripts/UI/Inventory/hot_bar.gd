extends Control
@onready var hotbar_slots : Array = get_tree().get_nodes_in_group("hb_slots")
@onready var inventory_ui: Control = $"../InventoryUI"
@onready var shop_ui: Control = $"../ShopUI"
@onready var navigation: Control = $"../Navigation"
@onready var ship_upgrades: Control = $"../ShipUpgrades"



# Images for hotbar is loaded here
var imgs = [Image.load_from_file("res://Assets/images/Hotbar/hotbar-0.jpeg"), Image.load_from_file("res://Assets/images/Hotbar/hotbar-1.jpeg")]
var hb_unsel = ImageTexture.create_from_image(imgs[0])
var hb_sel = ImageTexture.create_from_image(imgs[1])

# Index of current use (selected) hotbar slot
var selected_slot_index = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !shop_ui.visible and !navigation.visible and !ship_upgrades.visible:
		# Handle mouse scroll input
		if Input.is_action_just_released("scroll up"):
			selected_slot_index += 1
			if selected_slot_index > hotbar_slots.size() - 1:
				selected_slot_index = 0
			change_selected_slot_texture()
		if Input.is_action_just_released("scroll down"):
			selected_slot_index -= 1
			if selected_slot_index < 0:
				selected_slot_index = hotbar_slots.size() - 1
			change_selected_slot_texture()
			
		# Handle number (1-3) presets
		if Input.is_action_just_pressed("hotbar_1"):
			selected_slot_index = 0
			change_selected_slot_texture()
		if Input.is_action_just_pressed("hotbar_2"):
			selected_slot_index = 1
			change_selected_slot_texture()
		if Input.is_action_just_pressed("hotbar_3"):
			selected_slot_index = 2
			change_selected_slot_texture()
		
	#print("HotBar Slot: ", selected_slot_index)

# Refresh the UI to contain the current items in the hotbar
func update_hotbar_ui(inventory: Inventory):
	var hotbar_items = inventory.get_hotbar_items()
	for i in range(hotbar_slots.size()):
		var slot = hotbar_slots[i].get_children()
		var child = slot[0].get_children()
		
		if hotbar_items[i] != null:
			child[0].set_texture(hotbar_items[i].icon)
		else:
			child[0].set_texture(null)


## Changes the texture of a slot depending on if the user has selected that slot or not. If not selected, see hb_unsel. Otherwise, see hb_sel
func change_selected_slot_texture():
	for i in range(hotbar_slots.size()):
		if i == selected_slot_index:
			hotbar_slots[i].texture = hb_sel
			print(hotbar_slots[i].texture)
		else:
			hotbar_slots[i].texture = hb_unsel


# Get the current slot that is highlighted on screen
func get_selected_slot() -> int:
	return selected_slot_index


func _on_slot_item_swap(from_slot: int, to_slot: int, is_to_hotbar: bool, is_from_hotbar: bool) -> void:
	inventory_ui._on_item_swap(from_slot, to_slot, is_to_hotbar, is_from_hotbar)
