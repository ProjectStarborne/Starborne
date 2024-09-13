extends CanvasLayer

# Custom Signal that we can use to load levels once transition has finished
signal on_transition_finished

@onready var color_rect = $ColorRect
@onready var anim_player = $AnimationPlayer

func _ready():
	color_rect.visible = false
	
func transition():
	color_rect.visible = true
	anim_player.play("fade_to_black")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_black":
		on_transition_finished.emit()
		anim_player.play("fade_in_black")
	elif anim_name == "fade_in_black":
		color_rect.visible = false
