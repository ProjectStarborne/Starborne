extends Node2D

# Player variable for all things player related
@onready var player = %Player
# Inventory variable
@onready var inventory = $CanvasLayer/InventoryUI
# Pause Menu variable
@onready var pause_menu = $CanvasLayer/PauseMenu
var paused : bool = false
# Ship Upgrades UI variable
@onready var ship_upgrades_ui = $CanvasLayer/ShipUpgrades
# Label for first-time boot message
@onready var instruction_label: Label = $Player/InstructionLabel  

@onready var hot_bar: Control = %HotBar

@onready var file_manager: FileManager = $FileManager

var menu_open : bool = false
var current_menu = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	file_manager.load_game()	# Will return immediately if no save file is available
	hot_bar.update_hotbar_ui(Globals.inventory)
	
	# Show first-time instruction if no save file exists
	if is_first_time_boot():
		show_instruction_message()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Handle Inventory UI
	if Input.is_action_just_pressed("inventory"):
		if inventory.visible:
			inventory.close()
			menu_open = false
		else:
			inventory.open(player.inventory)
			menu_open = true
			current_menu = inventory
	
	# Handle Pause UI
	if Input.is_action_just_pressed("escape") and !paused and !menu_open:
		pause_menu.pause()
		paused = !paused
	elif Input.is_action_just_pressed("escape") and menu_open:
		current_menu.hide()
		menu_open = false
		current_menu = null

# Function to check if the save file exists
func is_first_time_boot() -> bool:
	return not FileAccess.file_exists("user://savegame.save")


func show_instruction_message():
	instruction_label.text = """
Use WASD to move around your ship.
To use items, drag them from your inventory to your hot bar,
then left-click to use. Speak to the overseer outside.
"""
	instruction_label.visible = true  # Make the label visible
	print("First-time boot detected. Showing instructions.")

	# Hide the label after 10 seconds
	await get_tree().create_timer(15.0).timeout
	instruction_label.visible = false
