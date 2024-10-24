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
# Add reference to shop UI
@onready var shop_ui = $CanvasLayer/ShopUI
# Add reference to ship navigation UI
@onready var navigation_ui = $CanvasLayer/Navigation
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
	
	# Connect the emitted signal to this script manually
	player.connect("picked_up_item", on_picked_up_item)

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
		
		# Handle shop menu 
	if Input.is_action_just_pressed("ui_select"):  # 'ui_select' is mapped to Space by default
		if shop_ui.visible:
			shop_ui.hide()  # Close the shop if it's already open
		else:
			close_inventory()  # Ensure the inventory is closed when opening the shop
			#close_ship_upgrades()
			shop_ui.show()  # Show the shop
	
			# Handle navigation menu 
	if Input.is_action_just_pressed("navigation_menu"):  # map 'navigation_menu' to 'N' in Input Map
		if navigation_ui.visible:
			navigation_ui.hide()  # Close the ship navigation if it's already open
		else:
			close_shop()
			close_inventory()
			navigation_ui.show()  # Show the ship navigation UI
	
		# Handle ship upgrade menu 
	if Input.is_action_just_pressed("ship_upgrades"):  # map 'ship_upgrade' to 'U' in Input Map
		if ship_upgrades_ui.visible:
			ship_upgrades_ui.hide()  # Close the ship upgrades if it's already open
		else:
			close_shop()
			close_inventory()
			ship_upgrades_ui.show()  # Show the ship upgrades UI

# Close the shop if it's open
func close_shop():
	if shop_ui.visible:
		shop_ui.hide()

# Close the inventory if it's open
func close_inventory():
	if inventory.visible:
		inventory.hide()

# Displays what is picked up to the screen
func on_picked_up_item(item : Item):
	print("Sent to world.gd")
	item_picked_up.visible = true
	item_picked_up.text = "Picked up " + item.name
	var animation = item_picked_up.get_node("AnimationPlayer")
	animation.play("fade_out")
