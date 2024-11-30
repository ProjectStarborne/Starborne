extends Area2D

class_name Door

@export var destination_level: String
@export var destination_door: String

@onready var file_manager: FileManager = $"../../FileManager"
@onready var spawn = $Spawn
@onready var player = %Player

@onready var barrier_collision = $Barrier/CollisionShape2D  # Reference to the barrier's CollisionShape2D

func _ready() -> void:
	# Ensure the barrier collision is disabled initially
	barrier_collision.disabled = true

func _process(delta: float) -> void:
	# Enable or disable the barrier collision based on is_shaking
	barrier_collision.disabled = not Globals.is_shaking

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Check if screen shake is in progress
		if Globals.is_shaking:
			print("Cannot exit the ship until travel is complete!")
			return  # Prevent exit while shaking
		
		body.velocity = lerp(body.velocity, Vector2.ZERO, 0.8)
		Globals.inventory = player.inventory
		
		# Save game if entering a specific level
		if destination_level == "shipinterior":
			file_manager.call_deferred("save_game")
		
		# Check if there is a queued level in Globals.next_level
		if Globals.next_level != null and Globals.next_level != "":
			# Use the queued level as the destination, then clear Globals.next_level
			destination_door = "newship"
			NavigationManager.go_to_level(Globals.next_level, destination_door)
			Globals.next_level = null  # Clear queued level after transition
		else:
			# Default behavior: change to the assigned destination level
			NavigationManager.go_to_level(destination_level, destination_door)
