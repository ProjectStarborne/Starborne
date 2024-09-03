extends Area2D

# Emitted when entering an anchor area.
signal anchor_detected(anchor)

#Emitted after exiting all anchor areas.
signal anchor_detached

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	emit_signal("anchor_detected", area)

# When exiting an area, ensure we're not entering another
func _on_area_exited(area: Area2D) -> void:
	var areas: Array = get_overlapping_areas()
	# Check that there is but one overlapping area left and that it's the one passed to this callback function.
	if get_overlapping_areas().size() == 1 and area == areas[0]:
		emit_signal("anchor_detached")
