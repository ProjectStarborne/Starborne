extends Node2D

@export var MeteorScene: PackedScene
@export var level_left: float = -2000.0
@export var level_right: float = 2100.0  # Adjust as per your level's width
@export var spawn_height: float = -1500.0  # Adjust to ensure meteors spawn off-screen

func _ready() -> void:
	randomize()
	$Timer.timeout.connect(_on_Timer_timeout)

func _on_Timer_timeout() -> void:
	spawn_meteor()

func spawn_meteor() -> void:
	# Randomize the horizontal spawn position across the entire level
	var x_position = randf() * (level_right - level_left) + level_left

	var meteor_instance = MeteorScene.instantiate()
	# Start the meteor above the visible area
	meteor_instance.global_position = Vector2(x_position, spawn_height)
	get_tree().current_scene.add_child(meteor_instance)
