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
	update_meteor_settings()  # Update settings based on the current level
	start_event_timer()  # Start the timer for the first meteor event

# Connect to the log pickup signal for log #4
	if Globals.current_level == 3:
		var log_node = get_node("../BrokenLog2") 
		if log_node:
			log_node.connect("log_pickup", Callable(self, "_on_log_pickup"))
			print("log node connected")

func _on_log_pickup(log_number: int) -> void:
	if log_number == 3 and Globals.current_level == 3:
		print("Log #4 picked up! Starting massive meteor shower.")
		start_massive_meteor_shower()


# Function to update meteor spawn settings based on the current level
func update_meteor_settings():
	match Globals.current_level:
		2:  # Asteroid Two
			min_meteors_per_event = 5
			max_meteors_per_event = 10
			min_time_between_events = 30
			max_time_between_events = 60
		3:  # Asteroid Three
			min_meteors_per_event = 5
			max_meteors_per_event = 25
			min_time_between_events = 20
			max_time_between_events = 50
		_:
			# Default settings (other levels)
			min_meteors_per_event = 5
			max_meteors_per_event = 50
			min_time_between_events = 5.0
			max_time_between_events = 15.0


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
	
	#print("Next meteor event in ", time_until_next_event, " seconds.")


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
	
	#print("Meteor event will end in ", event_duration, " seconds.")


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
	#print("Spawning meteor at impact_position:", impact_position)
	
	# Instantiate the meteor and set its target and spawn positions
	var meteor_instance = MeteorScene.instantiate()
	meteor_instance.target_position = impact_position  # Meteor will land at this position
	meteor_instance.global_position = get_meteor_start_position(impact_position, direction)  # Meteor spawns from a set direction
	meteor_instance.impact_indicator = impact_indicator  # Link the impact indicator to the meteor
	get_tree().current_scene.add_child(meteor_instance)


# Function to calculate the meteor's starting position based on the impact point and direction
func get_meteor_start_position(impact_position, direction):
	# Offset the meteor's starting position far off-screen (adjustable distance)
	var offset_distance = 2000  
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


func start_massive_meteor_shower():
	print("Massive meteor shower triggered!")

	# Save original settings
	var original_min_meteors = min_meteors_per_event
	var original_max_meteors = max_meteors_per_event
	var original_min_time = min_time_between_events
	var original_max_time = max_time_between_events
	var original_spawn_interval = meteor_spawn_interval  # Save the current spawn interval

	# Override settings for the massive meteor shower
	min_meteors_per_event = 100
	max_meteors_per_event = 200
	min_time_between_events = 0.5  # Reduced interval between meteor events
	max_time_between_events = 1.5
	meteor_spawn_interval = 0.25  # Faster meteor spawn interval

	# Start the meteor event with reduced intervals
	start_meteor_event()

	# Start a timer to reset settings after 2 minutes
	var reset_timer = Timer.new()
	reset_timer.wait_time = 120  # 2 minutes
	reset_timer.one_shot = true
	reset_timer.timeout.connect(func():
		# Restore original settings
		min_meteors_per_event = original_min_meteors
		max_meteors_per_event = original_max_meteors
		min_time_between_events = original_min_time
		max_time_between_events = original_max_time
		meteor_spawn_interval = original_spawn_interval  # Restore spawn interval
		print("Meteor shower ended. Restored original settings.")
	)
	add_child(reset_timer)
	reset_timer.start()
