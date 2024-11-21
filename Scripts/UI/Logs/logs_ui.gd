extends Control

@onready var entries: Array[Node] = $Logs.get_children()

var current_visible_entry: ScrollContainer

func _ready() -> void:
	connect_buttons()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_story"):
		self.visible = !self.visible
		get_tree().paused = !get_tree().paused

func connect_buttons() -> void:
	# Connect each of the slots "pressed" signal to our function
	for entry in entries:
		var entry_button = entry.get_child(0)
		
		# I cannot lie: this is Godot Voodoo shit.
		# We can represent an entire function as a "Callable"
		# Then we can pass the caller (entry) as an argument
		# by binding it to our callable made from our "on_entry_pressed" function
		# In summary: passes the button itself as a parameter
		var clicked_function = Callable(on_entry_pressed)
		clicked_function = clicked_function.bind(entry)
		entry_button.pressed.connect(clicked_function)


func on_entry_pressed(log: Control) -> void:
	var text_container = log.get_child(1)
	text_container.visible = true
	
	if !current_visible_entry:
		current_visible_entry = text_container
	elif current_visible_entry != text_container:
		current_visible_entry.visible = false
		current_visible_entry = text_container


func reveal_entry(entry_number: int) -> void:
	entries[entry_number].visible = true
