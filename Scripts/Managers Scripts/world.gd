extends Node2D

# Holds all the items ready to pickup
@export var pickups : Array[PackedScene]
# Player variable for all things player related
@onready var player = %Player
# Inventory variable
@onready var inventory = $CanvasLayer/InventoryUI
# Pause Menu variable
@onready var pause_menu = $CanvasLayer/PauseMenu
# Label for pickups
@onready var item_picked_up = $CanvasLayer/ItemPickupNotification

var paused : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Gets all markers in the level
	var markers = get_tree().get_nodes_in_group("Resource Spawn Marker")
	# Creates random num generator object
	var rng = RandomNumberGenerator.new()
	
	# For every marker that exists, choose a random pickup item and then
	# instantiate it at that marker's position
	for marker in markers:
		var random_number = rng.randi_range(0, pickups.size() - 1)
		var instance = pickups[random_number].instantiate()
		add_child(instance)
		instance.global_position = marker.global_position
	
	# Connect the emitted signal to this script manually
	player.connect("picked_up_item", on_picked_up_item)

func _process(delta: float) -> void:
	if Input.is_action_pressed("inventory"):
		inventory.open(player.inventory)
	
	if Input.is_action_just_pressed("pause") and !paused:
		pause_menu.pause()
		paused = !paused
	elif Input.is_action_just_pressed("pause") and paused:
		pause_menu.resume()
		paused = !paused
	

# Displays what is picked up to the screen
func on_picked_up_item(item : Item):
	print("Sent to world.gd")
	item_picked_up.visible = true
	item_picked_up.text = "Picked up " + item.name + " x1"
	var animation = item_picked_up.get_node("AnimationPlayer")
	animation.play("fade_out")
