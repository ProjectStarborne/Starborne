extends Button

@export var action : String
@export var primary : bool

var remap_mode = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	display_current_key()


func display_current_key():
	var action_events = InputMap.action_get_events(action)
	var current_key = ""
	if primary and action_events.size() > 0:
		current_key = action_events[0].as_text()
	elif not primary and action_events.size() > 1:
		current_key = action_events[1].as_text()
	text = current_key


func remap_action_to(event):
	var action_events = InputMap.action_get_events(action)
	InputMap.action_erase_events(action)
	var events = []
	if primary:
		events.append(event)
		# Don't lose the primary key
		if action_events.size() > 1:
			events.append(action_events[1])
	else:
		events.append(action_events[0])
		events.append(event)
	for e in events:
		InputMap.action_add_event(action, e)
	
	# Store new keymappings and change button text to new key
	KeyManager.keymaps[action] = events
	KeyManager.save_keymap()
	text = event.as_text()

func _on_toggled(toggled_on: bool) -> void:
	remap_mode = toggled_on
	if toggled_on:
		text = "Enter any key"
	else:
		display_current_key()

# Handle mouse and keyboard input remapping so infinite remap is impossible
func _input(event):
	if remap_mode:
		if event is InputEventKey or event is InputEventMouseButton:
			remap_action_to(event)
			if event is InputEventKey or not event.button_index == MOUSE_BUTTON_LEFT:
				button_pressed = false
