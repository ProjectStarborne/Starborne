extends Area2D

# This is used for in-level teleporation:
# the illusion of switching scenes and going to different areas

@export var to_teleporter: Area2D
@onready var outside_marker: Marker2D = $Marker2D
@onready var transition_manager = $TransitionManager

func _on_body_entered(body: Node2D) -> void:
	var new_position = to_teleporter.outside_marker.global_position
	
	transition_manager.transition()
	await transition_manager.on_transition_finished
	
	body.global_position = new_position
	if body.has_method("reset_camera"):
		body.reset_camera()
