extends Node

##
# FileManager Class
# 
# This class handles all saving and loading of game data to a save file.
# Nodes need to be modified slightly to be included in the save file.
# 
# Requirements:
# - A save() function in the root node's script that returns a dictionary of all the values needed 
#	to be stored. See player.gd for reference.
# - Be added to the global group "Persist"
# - If saving a custom object, you must create your own functions, to_dict and from_dict, to create 
#	dictionaries that can be appended to the main dictionary. See Inventory.gd for reference.
#	
class_name FileManager
	
# Go through everything in the persist category and ask them to return a
# dict of relevant variables.
func save_game():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)	
	
# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		print("No save file found.")
		return # Exit. We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	#var save_nodes = get_tree().get_nodes_in_group("Persist")
	#for i in save_nodes:
		#i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if parse_result != OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
			
		# Get the data from the JSON object.
		var node_data = json.data
		var node_name = node_data["name"]	# Get node name
		
		print("Current Scene: ", get_tree().current_scene)
		
		var node = null
		for n in get_tree().get_nodes_in_group("Persist"):
			if n.name == node_name:
				node = n
				break
				
		if node == null:
			print("Node ", node_name, " not found in scene. Skipping update.")
			continue
			
		#node.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "name" or i == "pos_x" or i == "pos_y":
				continue
			if i in node:
				if i == "inventory":
					node.inventory = node.inventory.from_dict(node_data["inventory"])
					Globals.inventory = node.inventory
				if i == "ship_inv":
					node.ship_inv = Inventory.new()
					node.ship_inv = node.ship_inv.from_dict(node_data["ship_inv"])
					Globals.ship_inventory = node.ship_inv
				node.set(i, node_data[i])
			else:
				print("Warning: Property ", i, " not found on ", node.name)
