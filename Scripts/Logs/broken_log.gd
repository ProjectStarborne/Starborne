extends Node2D

@export var log_number: int = -1
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var detector: Area2D = $Area2D

signal log_pickup(num)
signal notification(msg)

func _ready() -> void:
	animation_player.play("flashing")
	if Globals.track_logs[log_number]:
		queue_free()


func on_pickup(body: Node2D) -> void:
	log_pickup.emit(log_number)
	emit_signal("log_pickup", log_number)  # emit signal to start meteor shower if #4
	
	notification.emit(null, "Picked up Log #" + str(log_number + 1) + "!\n")
	if log_number == 0:
		notification.emit(null, "Press " + InputMap.action_get_events("toggle_story")[0].as_text() + " to access your PDA\n")
	queue_free()
