extends Node2D

# Holds all the items ready to pickup
@export var pickups : Array[PackedScene]

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
