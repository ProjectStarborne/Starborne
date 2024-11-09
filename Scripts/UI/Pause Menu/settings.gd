extends Control

@onready var window_size_option_button: OptionButton = $VBoxContainer/OptionsContainer/WindowSizeOptionButton
@onready var fullscreen_button: CheckButton = $VBoxContainer/OptionsContainer/FullscreenButton
@onready var master_volume_slider: HSlider = $VBoxContainer/OptionsContainer/MasterVolumeSlider
@onready var music_volume_slider: HSlider = $VBoxContainer/OptionsContainer/MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = $VBoxContainer/OptionsContainer/SFXVolumeSlider
@onready var ui_volume_slider: HSlider = $VBoxContainer/OptionsContainer/UIVolumeSlider



var options

func _ready():
	options = OptionsManager.read_options()
	if options.has("full_screen"):
		fullscreen_button.set_pressed_no_signal(options.full_screen)
	window_size_option_button.clear()
	var screen_size = DisplayServer.screen_get_size()
	var index = 0
	for size in OptionsManager.window_size_list:
		if size.width <= screen_size.x and size.height <= screen_size.y:
			window_size_option_button.add_item(str(size.width) + " x " + str(size.height))
			if options.has("window_width") and size.width == options.window_width and options.has("window_height") and size.height == options.window_height:
				window_size_option_button.select(index)
			index += 1
			
	master_volume_slider.value = options.master_volume if options.has("master_volume") else 1.0
	music_volume_slider.value = options.music_volume if options.has("music_volume") else 1.0
	sfx_volume_slider.value = options.sfx_volume if options.has("sfx_volume") else 1.0
	ui_volume_slider.value = options.ui_volume if options.has("ui_volume") else 1.0


func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		back_to_pause_menu()


func _on_back_button_pressed() -> void:
	back_to_pause_menu()


func back_to_pause_menu():
	queue_free()


func _on_window_size_option_button_item_selected(index: int) -> void:
	var size = OptionsManager.window_size_list[index]
	options.window_width = size.width
	options.window_height = size.height
	OptionsManager.write_options(options)
	OptionsManager.resize_window()


func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	options.full_screen = toggled_on
	OptionsManager.write_options(options)
	OptionsManager.set_window_mode()
	OptionsManager.resize_window()


func _on_master_volume_slider_value_changed(value: float) -> void:
	options.master_volume = value
	OptionsManager.write_options(options)
	SoundManager.set_master_volume(value)


func _on_music_volume_slider_value_changed(value: float) -> void:
	options.music_volume = value
	OptionsManager.write_options(options)
	SoundManager.set_music_volume(value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	options.sfx_volume = value
	OptionsManager.write_options(options)
	SoundManager.set_sfx_volume(value)


func _on_ui_volume_slider_value_changed(value: float) -> void:
	options.ui_volume = value
	OptionsManager.write_options(options)
	SoundManager.set_ui_volume(value)


func _on_key_binding_button_pressed() -> void:
	var settings_scene = load("res://Scenes/UI/key_binding.tscn")
	var instance = settings_scene.instantiate()
	add_child(instance)
