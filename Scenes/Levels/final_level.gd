extends Node2D

const TITLE_SCREEN = preload("res://Scenes/Levels/title_screen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if Input.is_anything_pressed():
		get_tree().change_scene_to_packed(TITLE_SCREEN)
