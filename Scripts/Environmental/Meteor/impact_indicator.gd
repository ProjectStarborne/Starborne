extends Node2D

# Called when the impact_indicator node is added to the scene
func _ready():
	# Connect the Timer node's "timeout" signal to the _on_Timer_timeout function
	# This sets up an action to happen when the Timer reaches its timeout.
	$Timer.timeout.connect(_on_Timer_timeout)

# Function called when the Timer times out
func _on_Timer_timeout():
	# This function queues the impact indicator node for deletion (removes it from the scene)
	# queue_free() will safely remove the node once all operations are completed
	queue_free()
