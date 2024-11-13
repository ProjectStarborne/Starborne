extends Node2D

## Holds all the items ready to pickup
@export var ore_nodes : Array[PackedScene]
# Player variable for all things player related
@onready var player = %Player
# Inventory variable
@onready var inventory = $CanvasLayer/InventoryUI
# Pause Menu variable
@onready var pause_menu = $CanvasLayer/PauseMenu
# Label for pickups
@onready var item_picked_up = $CanvasLayer/ItemPickupNotification
# Add reference to ship upgrades UI
@onready var ship_upgrades_ui = $CanvasLayer/ShipUpgrades

var paused : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	# Gets all markers in the level
	var markers = get_tree().get_nodes_in_group("Resource Spawn Marker")
	# Creates random num generator objectd
	var rng = RandomNumberGenerator.new()
	
	# For every marker that exists, choose a random pickup item and then
	# instantiate it at that marker's position
	for marker in markers:
		var random_number = rng.randi_range(0, ore_nodes.size() - 1)
		var instance = ore_nodes[random_number].instantiate()
		add_child(instance)
		instance.global_position = marker.global_position
	

func _process(delta: float) -> void:
	# Handle Inventory UI
	if Input.is_action_just_pressed("inventory") and !ship_upgrades_ui.visible :
		if inventory.visible:
			inventory.close()
		else:
			inventory.open(player.inventory)
	
	# Handle Pause UI
	if Input.is_action_just_pressed("pause") and !paused:
		close_ship_upgrades()
		pause_menu.pause()
		paused = !paused
	elif Input.is_action_just_pressed("pause") and paused:
		pause_menu.resume()
		paused = !paused
	
		# Handle ship upgrade menu 
	if Input.is_action_just_pressed("ship_upgrades"):  # map 'ship_upgrade' to 'U' in Input Map
		if ship_upgrades_ui.visible:
			ship_upgrades_ui.hide()  # Close the ship upgrades if it's already open
		else:
			inventory.close()
			ship_upgrades_ui.show()  # Show the ship upgrades UI


#Close the ship upgrades UI if it's open
func close_ship_upgrades():
	if ship_upgrades_ui.visible:
		ship_upgrades_ui.hide()

# Displays what is picked up to the screen
func _on_player_picked_up_item(item: Item, fail: bool) -> void:
	print("Sent to world.gd")
	
	if not fail:
		item_picked_up.visible = true
		item_picked_up.text += "Picked up " + item.name + "\n"
		var animation = item_picked_up.get_node("AnimationPlayer")
		animation.play("fade_out")
