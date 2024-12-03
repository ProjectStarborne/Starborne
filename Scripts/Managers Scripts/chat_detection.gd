extends Area2D

var player_in_area = false
@export var interact_key: String = "interact"  # Represents the "E" key by default

@onready var player = get_node("/root/Environment2/Player")  # Update this path to your actual scene structure
@onready var interaction_label = player.get_node("InteractionLabel")  # Label above the player's head

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_area:
		if Input.is_action_just_pressed(interact_key):
			# Run Dialogue
			run_dialogue("overseer_timeline")

# Function to run dialogue
func run_dialogue(name: String):
	Dialogic.start(name)

# Detect when the player enters the interaction area
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = true
		print("Player is near overseer. Press E to interact.")
		show_interaction_message("Press E to interact")

# Detect when the player leaves the interaction area
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_area = false
		print("Player has left the overseer area.")
		hide_interaction_message()

# Show the interaction message over the player's head
func show_interaction_message(message: String):
	if interaction_label:
		interaction_label.text = message
		interaction_label.visible = true

# Hide the interaction message
func hide_interaction_message():
	if interaction_label:
		interaction_label.visible = false
