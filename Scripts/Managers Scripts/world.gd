extends Node2D

## Holds all the items ready to pickup
@export var ore_nodes : Array[PackedScene]
# Player variable for all things player related
@onready var player = %Player
# Inventory variable
@onready var inventory = $CanvasLayer/InventoryUI
# Pause Menu variable
@onready var pause_menu = $CanvasLayer/PauseMenu
# Label for notifications
@onready var notifications: ScrollContainer = $CanvasLayer/Notifications

# Add reference to ship upgrades UI
@onready var ship_upgrades_ui = $CanvasLayer/ShipUpgrades

var paused : bool = false
var menu_open : bool = false

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
		instance.connect("upgrade_notif", notif)
		
	player.connect("picked_up_item", notif)

func _process(_delta: float) -> void:
	# Handle Inventory UI
	if Input.is_action_just_pressed("inventory"):
		if inventory.visible:
			inventory.close()
			menu_open = false
		else:
			inventory.open(player.inventory)
			menu_open = true
	
	# Handle Pause UI
	if Input.is_action_just_pressed("escape") and !paused && !menu_open:
		close_ship_upgrades()
		pause_menu.pause()
		paused = !paused


func disable_menu_opening(open : bool):
	menu_open = open

#Close the ship upgrades UI if it's open
func close_ship_upgrades():
	if ship_upgrades_ui.visible:
		ship_upgrades_ui.hide()

# Displays what is picked up to the screen
func notif(item: Item, msg : String) -> void:
	print("Sent to world.gd")
	notifications.enter_message(msg)
