extends Node2D

# Scene to be used for spawning meteors
@export var MeteorScene: PackedScene
# Scene to be used for spawning impact indicators (warning before the meteor falls)
@export var ImpactIndicatorScene: PackedScene
# Time between the warning and the actual meteor impact
@export var warning_time: float = 2.0
# Minimum and maximum number of meteors per event
@export var min_meteors_per_event: int = 5
@export var max_meteors_per_event: int = 50
# Time range in seconds for random intervals between meteor events
@export var min_time_between_events: float = 5.0
@export var max_time_between_events: float = 15.0
# Time interval in seconds between each meteor during a meteor event
@export var meteor_spawn_interval: float = 0.5
# Possible directions from which meteors can spawn ("top", "bottom", "left", or "right" of the map)
var possible_directions = ["top", "bottom", "left", "right"]


# Called when the node is added to the scene
func _ready() -> void:
	randomize()  # Randomize the seed for random number generation
	start_event_timer()  # Start the timer for the first meteor event


# Function to start a timer for the next meteor event
func start_event_timer():
	# Calculate a random time until the next meteor event (between min and max times)
	var time_until_next_event = randf() * (max_time_between_events - min_time_between_events) + min_time_between_events
	
	# Create a timer to trigger the next event
	var event_timer = Timer.new()
	event_timer.wait_time = time_until_next_event
	event_timer.one_shot = true  # Timer should only trigger once
	event_timer.timeout.connect(_on_event_timer_timeout)  # Connect timer to event handler
	add_child(event_timer)  # Add the timer to the scene
	event_timer.start()  # Start the timer
	
	print("Next meteor event in ", time_until_next_event, " seconds.")


# Called when the event timer finishes, starting a new meteor event
func _on_event_timer_timeout():
	start_meteor_event()  # Begin the meteor event


# Function to start a meteor event
func start_meteor_event():
	# Randomly decide how many meteors will spawn in this event
	var num_meteors = randi() % (max_meteors_per_event - min_meteors_per_event + 1) + min_meteors_per_event

	# Randomly pick a direction from which all meteors will spawn
	var direction = possible_directions[randi() % possible_directions.size()]
	
	print("Starting meteor event with ", num_meteors, " meteors from ", direction)

	# Spawn meteors one by one with a delay between each
	for i in range(num_meteors):
		var delay = i * meteor_spawn_interval  # Delay for each meteor
		var meteor_timer = Timer.new()
		meteor_timer.wait_time = delay
		meteor_timer.one_shot = true  # Each meteor spawns only once
		meteor_timer.timeout.connect(_spawn_meteor_warning.bind(direction))  # Connect timer to meteor spawn function
		add_child(meteor_timer)
		meteor_timer.start()

	# Calculate the total duration of the event (time until all meteors finish spawning)
	var event_duration = num_meteors * meteor_spawn_interval + warning_time + 1.0  # Buffer time added
	var event_end_timer = Timer.new()
	event_end_timer.wait_time = event_duration
	event_end_timer.one_shot = true  # Event ends once after all meteors spawn
	event_end_timer.timeout.connect(_on_event_end_timer_timeout)  # Connect timer to end event function
	add_child(event_end_timer)
	event_end_timer.start()
	
	print("Meteor event will end in ", event_duration, " seconds.")


# Called when the meteor event ends, resetting the timer for the next event
func _on_event_end_timer_timeout():
	start_event_timer()


# Function to spawn a meteor warning (impact indicator) before the meteor falls
func _spawn_meteor_warning(direction):
	# Get the meteor landing area where meteors can impact
	var landing_area = get_tree().current_scene.get_node("/root/Environment/MeteorLandingArea")
	if landing_area == null:
		print("Error: 'MeteorLandingArea' not found.")
		return

	# Get a random impact position within the landing area
	var impact_position = get_random_point_in_area(landing_area)

	# Spawn the impact indicator at the calculated position
	var indicator_instance = ImpactIndicatorScene.instantiate()
	indicator_instance.global_position = impact_position
	get_tree().current_scene.add_child(indicator_instance)

	# Schedule the meteor to spawn after the warning time
	var meteor_timer = Timer.new()
	meteor_timer.wait_time = warning_time
	meteor_timer.one_shot = true  # Only spawn the meteor once
	meteor_timer.timeout.connect(_spawn_meteor.bind(impact_position, indicator_instance, direction))  # Connect timer to meteor spawn
	add_child(meteor_timer)
	meteor_timer.start()


# Function to spawn a meteor at the impact position
func _spawn_meteor(impact_position, impact_indicator, direction):
	print("Spawning meteor at impact_position:", impact_position)
	
	# Instantiate the meteor and set its target and spawn positions
	var meteor_instance = MeteorScene.instantiate()
	meteor_instance.target_position = impact_position  # Meteor will land at this position
	meteor_instance.global_position = get_meteor_start_position(impact_position, direction)  # Meteor spawns from a set direction
	meteor_instance.impact_indicator = impact_indicator  # Link the impact indicator to the meteor
	get_tree().current_scene.add_child(meteor_instance)


# Function to calculate the meteor's starting position based on the impact point and direction
func get_meteor_start_position(impact_position, direction):
	# Offset the meteor's starting position far off-screen (adjustable distance)
	var offset_distance = 1500  
	var start_position = impact_position

	# Adjust the starting position based on the direction the meteors are coming from
	match direction:
		"top":
			start_position += Vector2(0, -offset_distance)  # Spawn above the screen
		"bottom":
			start_position += Vector2(0, offset_distance)  # Spawn below the screen
		"left":
			start_position += Vector2(-offset_distance, 0)  # Spawn left of the screen
		"right":
			start_position += Vector2(offset_distance, 0)  # Spawn right of the screen
	return start_position


# Function to get a random valid point within a polygonal landing area (our asteroid map)
func get_random_point_in_area(area: Area2D) -> Vector2:
	# Get the CollisionPolygon2D node defining the meteor landing area
	var collision_polygon = area.get_node("CollisionPolygon2D")
	if collision_polygon == null:
		print("Error: 'CollisionPolygon2D' not found under 'MeteorLandingArea'.")
		return area.global_position

	# Get the polygon points that define the area boundaries
	var polygon_points = collision_polygon.polygon
	if polygon_points.size() == 0:
		print("Error: CollisionPolygon2D has no points.")
		return area.global_position

	# Calculate the bounding box of the polygon
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	for point in polygon_points:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)

	# Try to generate a random point within the polygon
	var point = Vector2()
	var max_attempts = 100  # Limit attempts to prevent infinite loops
	var attempts = 0
	while attempts < max_attempts:
		point.x = randf() * (max_x - min_x) + min_x
		point.y = randf() * (max_y - min_y) + min_y

		# Check if the random point is within the polygon
		if Geometry2D.is_point_in_polygon(point, polygon_points):
			return point  # Valid point found
		attempts += 1

	print("Failed to find a valid point within the polygon after max attempts.")
	return area.global_position  # Default to the center if no valid point found
