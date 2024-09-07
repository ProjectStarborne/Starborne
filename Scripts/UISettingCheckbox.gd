extends Control

# Emitted when the 'CheckBox' State changes.
signal toggled(is_button_pressed)

# The text of the Label should be changed to identify the setting.
# Using a setter lets us change the text when the 'title' variable changes
@export var title = "" : set = set_title

# Store a reference to the Label node
@onready var label := $Label

func _on_check_box_toggled(toggled_on: bool) -> void:
	emit_signal("toggled", toggled_on)
	
# Executed when 'title' variable changes.
func set_title(value: String) -> void:
	title = value
	
	# Wait until the scene is ready if 'label' is null.
	if not label:
		await self.ready
	
	# Update the label's text
	label.text = title
