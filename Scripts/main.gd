extends Node2D

@onready var pause_menu = %PauseMenu
@onready var settings_menu = %Settings
var paused = false
var change_settings = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
		
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
		
	paused = !paused


func settingsMenu():
	if change_settings:
		settings_menu.show()
	else:
		settings_menu.hide()
	
	change_settings = !change_settings
	
func update_settings(settings: Dictionary) -> void:
	OS.window_fullscreen = settings.fullscreen
	get_tree().set_screen_stretch(
		SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, settings.resolution
	)
	OS.set_window_size(settings.resolution)
	OS.vsync_enabled = settings.vsync
	
func __on_UIVideoSettings_apply_button_pressed(settings) -> void:
	update_settings(settings)
