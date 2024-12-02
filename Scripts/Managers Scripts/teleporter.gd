extends Area2D

# This is used for in-level teleporation:
# the illusion of switching scenes and going to different areas

@export var to_teleporter: Area2D
@onready var outside_marker: Marker2D = $Marker2D

func _on_body_entered(body: Node2D) -> void:
	var new_position = to_teleporter.outside_marker.global_position
	
	body.global_position = new_position
	if body.has_method("reset_camera"):
		body.reset_camera()
