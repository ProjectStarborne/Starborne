extends Control

@onready var hotbar_slots : Array = get_tree().get_nodes_in_group("hb_slots")
@onready var animation_player = $AnimationPlayer

# Images for hotbar is loaded here
var imgs = [Image.load_from_file("res://Assets/images/Hotbar/hotbar-0.jpeg"), Image.load_from_file("res://Assets/images/Hotbar/hotbar-1.jpeg")]
var hb_unsel = ImageTexture.create_from_image(imgs[0])
var hb_sel = ImageTexture.create_from_image(imgs[1])

# Index of current use (selected) hotbar slot
var selected_slot_index = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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

## Changes the texture of a slot depending on if the user has selected that slot or not. If not selected, see hb_unsel. Otherwise, see hb_sel
func change_selected_slot_texture():
	for i in range(hotbar_slots.size()):
		if i == selected_slot_index:
			hotbar_slots[i].texture = hb_sel
			print(hotbar_slots[i].texture)
		else:
			hotbar_slots[i].texture = hb_unsel
			
