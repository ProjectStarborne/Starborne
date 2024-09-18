extends Node

@export var pickups : Array[PackedScene]

func _ready():
	var markers = get_tree().get_nodes_in_group("Resource_Spawn")
	var rng = RandomNumberGenerator.new()
	
	for marker in markers:
		var random_number = rng.randi_range(0, pickups.size() - 1)
		var instance = pickups[random_number].instantiate()
		instance.global_position = marker.global_position
		print("First marker pos: ", marker.global_position, 
		"Pickup pos: ", instance.global_position)
		add_child(instance)
