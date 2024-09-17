extends Node2D

func _ready():
	$Timer.timeout.connect(_on_Timer_timeout)

func _on_Timer_timeout():
	queue_free()
