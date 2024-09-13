extends Area2D

class_name Door

@export var destination_level: String
@export var destination_door: String

@onready var spawn = $Spawn

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerShip: # TODO: or Player
		body.velocity = lerp(body.velocity, Vector2.ZERO, 0.8)
		NavigationManager.go_to_level(destination_level, destination_door)
