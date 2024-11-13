extends Area2D

class_name Door

@export var destination_level: String
@export var destination_door: String

@onready var file_manager: FileManager = $"../../FileManager"

@onready var spawn = $Spawn

@onready var player = %Player

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): # TODO: or Player
		body.velocity = lerp(body.velocity, Vector2.ZERO, 0.8)
		Globals.inventory = player.inventory
		#player.save()
		if destination_level == "shipinterior":
			file_manager.call_deferred("save_game")
		NavigationManager.go_to_level(destination_level, destination_door)
		
