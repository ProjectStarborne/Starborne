extends Control

@onready var world = get_parent().get_parent()
var paused = false

func _process(delta):
	if Input.is_action_just_pressed("pause") && paused:
		resume()

#func _ready() -> void:
	#$AnimationPlayer.play("RESET")
	
func pause() -> void:
	print("Paused")
	get_tree().paused = true
	show()
	$AnimationPlayer.play("Blur")
	await get_tree().create_timer(1).timeout
	paused = true
	
func resume():
	print("Resuming Game...")
	$AnimationPlayer.play_backwards("Blur")
	await $AnimationPlayer.animation_finished
	hide()
	get_tree().paused = false
	world.paused = false
	paused = false
	

func _on_resume_button_pressed() -> void:
	resume()

# This will open up video and audio settings when applicable
func _on_settings_button_pressed() -> void:
	var settings_scene = load("res://Scenes/UI/settings.tscn")
	var instance = settings_scene.instantiate()
	add_child(instance)

# Quit the game entirely (Should take it to main menu when menu is made)
func _on_quit_button_pressed() -> void:
	get_tree().quit()
