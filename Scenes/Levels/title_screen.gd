extends Control

# Custom Signal that we can use to load levels once transition has finished
signal on_transition_finished

@onready var color_rect = $Fade/ColorRect2
@onready var anim_player = $Fade/AnimationPlayer
@onready var player_anim = $AnimatedSprite2D

func _ready():
	color_rect.visible = false
	player_anim.play("walking")

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/shipinterior.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
