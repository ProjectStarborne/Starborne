extends Control


func open() -> void:
	get_tree().paused = true
	show()

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_close_button_pressed() -> void:
	get_tree().paused = false
	hide()
