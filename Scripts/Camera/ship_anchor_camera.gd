extends Camera2D

# Distance to target which the camera slows down
const SLOWDOWN_RADIUS = 300.0

@export var max_speed = 2000.0
# Mass to slow down the camera movement
@export var mass = 2.0

var _velocity = Vector2.ZERO
# Global position of an anchor area. If it's equal to Vector2.ZERO, camera has no anchor point and follows owner.
var anchor_position := Vector2.ZERO
var target_zoom = 5.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setting a node as top-level makes it move independentlly of its parent
	set_as_top_level(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	update_zoom()
	# The camera's target position is either the anchor_position if the value isn't Vector2.ZERO or the owner's position. The owner is the root node of the scene in which the camera is instanced.
	var target_position: Vector2 = (
		owner.global_position
		if anchor_position.is_equal_approx(Vector2.ZERO)
		else anchor_position
	)
	
	arrive_to(target_position)
	
# Entering the Anchor we receive the anchor object and change our anchor_position and target_zoom
func _on_AnchorDetector2D_anchor_detected(anchor: Area2D) -> void:
	anchor_position = anchor.global_position
	target_zoom = anchor.zoom_level
	
# Leaving the anchor the zoom return to 1.0 and the camera's center to the player
func _on_AnchorDetector2D_anchor_detached() -> void:
	anchor_position = Vector2.ZERO
	target_zoom = 3.0

# Smoothly update the zoom level using a linear interpolation (lerp)
func update_zoom() -> void:
	if not is_equal_approx(zoom.x, target_zoom):
		var new_zoom_level: float = lerp(zoom.x, target_zoom, 1.0 - pow(0.008, get_physics_process_delta_time()))
		zoom = Vector2(new_zoom_level, new_zoom_level)

# Gradually steers the camera to the target_position using the arrive steering behavior		
func arrive_to(target_position: Vector2) -> void:
	var distance_to_target = position.distance_to(target_position)
	# Approach the target_position at max_speed, taking the zoom into account, until we get close to the target.
	
	var desired_velocity = (target_position - position).normalized() * max_speed * zoom.x
	# If we're close enough to target, we gradually slow down the camera
	if distance_to_target < SLOWDOWN_RADIUS * zoom.x:
		desired_velocity *= (distance_to_target / (SLOWDOWN_RADIUS * zoom.x))
		
	_velocity += (desired_velocity - _velocity) / mass
	position += _velocity * get_physics_process_delta_time()


##### CAMERA SCREEN SHAKE #####
# Variables for screen shake
var shake_duration = 0.0
var shake_intensity = 0.0
var shake_timer = 0.0

# Call this function to start screen shake
func start_screen_shake(duration: float, intensity: float) -> void:
	shake_duration = duration
	shake_intensity = intensity
	shake_timer = duration
