extends Node2D

# Player variable for all things player related
@onready var player = %Player
# Inventory variable
@onready var inventory = $CanvasLayer/InventoryUI
# Pause Menu variable
@onready var pause_menu = $CanvasLayer/PauseMenu
var paused : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handle Inventory UI
	if Input.is_action_just_pressed("inventory"):
		if inventory.visible:
			inventory.close()
		else:
			inventory.open(player.inventory)
	
	# Handle Pause UI
	if Input.is_action_just_pressed("pause") and !paused:
		pause_menu.pause()
		paused = !paused
	elif Input.is_action_just_pressed("pause") and paused:
		pause_menu.resume()
		paused = !paused
