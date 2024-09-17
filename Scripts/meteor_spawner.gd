extends Node2D

@export var MeteorScene: PackedScene
@export var ImpactIndicatorScene: PackedScene
@export var spawn_height: float = -1500.0
@export var warning_time: float = 2.0
@export var ground_left: float = -2000.0
@export var ground_right: float = 2100.0
@export var ground_y_min: float = -1000.0
@export var ground_y_max: float = 1000.0


func _ready() -> void:
	randomize()
	$Timer.timeout.connect(_on_Timer_timeout)

func _on_Timer_timeout() -> void:
	spawn_meteor_warning()


func spawn_meteor_warning() -> void:
	# Select a random impact point on the ground
	var impact_x = randf() * (ground_right - ground_left) + ground_left
	var impact_y = randf() * (ground_y_max - ground_y_min) + ground_y_min
	var impact_position = Vector2(impact_x, impact_y)

	# Spawn the impact indicator
	var indicator_instance = ImpactIndicatorScene.instantiate()
	indicator_instance.global_position = impact_position
	get_tree().current_scene.add_child(indicator_instance)

	# Schedule the meteor to spawn after warning_time seconds
	var meteor_timer = Timer.new()
	meteor_timer.wait_time = warning_time
	meteor_timer.one_shot = true
	meteor_timer.timeout.connect(_spawn_meteor.bind(impact_position, indicator_instance))
	get_tree().current_scene.add_child(meteor_timer)
	meteor_timer.start()

func _spawn_meteor(impact_position, impact_indicator):
	print("Spawning meteor at impact_position:", impact_position)
	var meteor_instance = MeteorScene.instantiate()
	meteor_instance.target_position = impact_position
	meteor_instance.global_position = impact_position + Vector2(0, spawn_height)
	# Pass the impact_indicator to the meteor instance
	meteor_instance.impact_indicator = impact_indicator
	get_tree().current_scene.add_child(meteor_instance)
