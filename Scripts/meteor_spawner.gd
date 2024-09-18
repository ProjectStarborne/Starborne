extends Node2D

# The PackedScene for the meteor that will be spawned
@export var MeteorScene: PackedScene
# The PackedScene for the impact indicator, which warns where a meteor will land
@export var ImpactIndicatorScene: PackedScene
# The height at which meteors spawn above the screen 
@export var spawn_height: float = -1500.0
# The delay in seconds between the warning indicator and the meteor impact
@export var warning_time: float = 2.0


# This function is called when the node is added to the scene
func _ready() -> void:
	# Randomizes the random number generator seed 
	randomize()
	# Connects the Timer node's "timeout" signal to the _on_Timer_timeout function
	$Timer.timeout.connect(_on_Timer_timeout)


# Called when the Timer times out (after a certain delay)
func _on_Timer_timeout() -> void:
	# Spawns the meteor warning at a random position within a defined landing area
	spawn_meteor_warning()


# Function to handle spawning the meteor warning and scheduling the meteor
func spawn_meteor_warning() -> void:
	# Select a random impact point within the specified "MeteorLandingArea" in the game world
	var landing_area = get_tree().current_scene.get_node("/root/Environment/MeteorLandingArea")
	var impact_position = get_random_point_in_area(landing_area)

	# Instantiate the impact indicator scene and position it at the selected impact point
	var indicator_instance = ImpactIndicatorScene.instantiate()
	indicator_instance.global_position = impact_position
	get_tree().current_scene.add_child(indicator_instance)

	# Create a Timer to delay the meteor's appearance by the warning_time (2 seconds)
	var meteor_timer = Timer.new()
	meteor_timer.wait_time = warning_time
	meteor_timer.one_shot = true  # Ensure the timer only runs once

	# Connect the Timer's "timeout" signal to the _spawn_meteor function, passing in the impact position and indicator
	meteor_timer.timeout.connect(_spawn_meteor.bind(impact_position, indicator_instance))

	# Add the Timer node to the current scene and start it
	get_tree().current_scene.add_child(meteor_timer)
	meteor_timer.start()


# Function that spawns a meteor at the specified impact position
func _spawn_meteor(impact_position, impact_indicator):
	# Print the impact position to the console for debugging purposes
	print("Spawning meteor at impact_position:", impact_position)

	# Instantiate the meteor scene and set its target and spawn positions
	var meteor_instance = MeteorScene.instantiate()
	meteor_instance.target_position = impact_position  # Set the target position where the meteor will land
	meteor_instance.global_position = impact_position + Vector2(0, spawn_height)  # Set the initial spawn position

	# Assign the impact indicator to the meteor instance (could be used for further functionality)
	meteor_instance.impact_indicator = impact_indicator

	# Add the meteor to the current scene
	get_tree().current_scene.add_child(meteor_instance)


# Function that returns a random point within a given Area2D (used for randomizing meteor landing points)
func get_random_point_in_area(area: Area2D) -> Vector2:
	# Get the CollisionPolygon2D node from the landing area (used to define the boundaries for valid impact points)
	var collision_polygon = area.get_node("CollisionPolygon2D")

	# Extract the polygon's points (which define its shape)
	var polygon_points = collision_polygon.polygon

	# Manually calculate the bounding box for the polygon (min/max X and Y coordinates)
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	
	# Iterate through all polygon points to find the min and max X/Y coordinates
	for point in polygon_points:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
	
	# Initialize variables for generating random points within the bounding box
	var point = Vector2()
	var max_attempts = 100  # Limit the number of attempts to prevent an infinite loop
	var attempts = 0

	# Try to generate a random point within the polygon up to max_attempts times
	while attempts < max_attempts:
		# Generate random X and Y values within the bounding box
		point.x = randf() * (max_x - min_x) + min_x
		point.y = randf() * (max_y - min_y) + min_y
		
		# Check if the random point is inside the polygon using Godot's Geometry2D helper
		if Geometry2D.is_point_in_polygon(point, polygon_points):
			return point  # If the point is valid, return it as the impact position

		# If the point is outside the polygon, try again
		attempts += 1
	
	# If no valid point is found after max_attempts, print a warning and default to the center of the area
	print("Failed to find a valid point within the polygon after max attempts.")
	return area.global_position  # Default to the global position of the area (the center)
