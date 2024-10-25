extends Node

# TODO: Create a less manual labor method for adding scenes
# - maybe check some other projects for inspiration?

const scene_space = preload("res://Scenes/Levels/world_space.tscn")
const scene_asteroid = preload("res://Scenes/Levels/world_asteroid.tscn")
const ship_interior = preload("res://Scenes/Levels/shipinterior.tscn")
const scene_asteroid_two = preload("res://Scenes/Levels/asteroid_two.tscn")  # Adjust path if needed


var spawn_door_tag

# Changes scene to specific door
func go_to_level(level_tag, destination_tag):
	var scene_to_load
	
	# Dynamically find the player node, adjusting for different scene structures
	var player: Node = null

	# Check if we are in the Environment scene
	if get_tree().current_scene.name == "Environment":
		player = get_node_or_null("/root/Environment/Player")

	# Check if we are in the Shipinterior scene
	elif get_tree().current_scene.name == "Shipinterior":
		player = get_node_or_null("/root/Shipinterior/Player")

	# If player node is found, save player stats
	if player:
		print("Player found:", player)
		player.save_player_stats()
	else:
		print("Player not found!")

	# Determine which scene to load based on the level_tag
	match level_tag:
		"world_space":
			scene_to_load = scene_space
		"world_asteroid":
			scene_to_load = scene_asteroid
		"shipinterior":
			scene_to_load = ship_interior
		"asteroid_two":
			scene_to_load = scene_asteroid_two

	if scene_to_load != null:
		TransitionManager.transition()
		await TransitionManager.on_transition_finished
		spawn_door_tag = destination_tag
		get_tree().change_scene_to_packed(scene_to_load)
