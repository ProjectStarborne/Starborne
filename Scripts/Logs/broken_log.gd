extends Node2D

@export var log_number: int = -1
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var detector: Area2D = $Area2D

signal log_pickup(num)

func _ready() -> void:
	animation_player.play("flashing")


func on_pickup(body: Node2D) -> void:
	log_pickup.emit(log_number)
	queue_free()
