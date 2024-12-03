extends Control



# Custom Signal that we can use to load levels once transition has finished
signal on_transition_finished

@onready var color_rect: ColorRect = $Fade/ColorRect2
@onready var anim_player: AnimationPlayer = $Fade/AnimationPlayer
@onready var parallax_player: AnimationPlayer = $Parallax/AnimationPlayer
@onready var options_player: AnimationPlayer = $AnimationPlayer
@onready var player_anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var settings: Control = $Settings

func _ready():
	color_rect.visible = false
	player_anim.play("walking")
	parallax_player.play("parallax")
	settings.setup_display()

# Handles button presses
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/shipinterior.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

# Handles button animations - connected via signals and passes its own path
func _on_button_hover(node_path: NodePath) -> void:
	var tween: Tween = create_tween()
	var hovered_button: Button = get_node(node_path)
	var new_pos = Vector2(15, hovered_button.position.y)
	
	tween.tween_property(hovered_button, "position", new_pos, 0.1)

func _on_button_exit(node_path: NodePath) -> void:
	var tween: Tween = create_tween()
	var hovered_button: Button = get_node(node_path)
	var old_pos = Vector2(0, hovered_button.position.y)
	
	tween.tween_property(hovered_button, "position", old_pos, 0.3)


func _on_options_pressed() -> void:
	options_player.play('options_transition')
	settings.is_open = true
