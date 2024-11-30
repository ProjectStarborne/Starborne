extends HBoxContainer

@onready var health_bar: ProgressBar = $"ControlHealth/HealthBar"
@onready var oxygen_bar: ProgressBar = $"ControlOxygen/OxygenBar"

func _ready() -> void:
	# Initially access player's health to properly correspond with bar
	update_health()
	update_oxygen()


func update_health() -> void:
	health_bar.value = %Player.current_health
	update_health_color()


func update_oxygen() -> void:
	oxygen_bar.value = %Player.current_oxygen
	update_oxygen_color()


func update_health_color() -> void:
	var curr = float(%Player.current_health)
	var max = float(%Player.max_health)
	var health_percentage = curr / max
	
	# Get the fill stylebox of the health bar to change its background color
	var fill_stylebox = health_bar.get("theme_override_styles/fill")
	if fill_stylebox == null:
		# If there's no existing style, create a new one
		fill_stylebox = StyleBoxFlat.new()
		health_bar.set("theme_override_styles/fill", fill_stylebox)
	
	# Set the color of the health bar based on the health percentage:
	if health_percentage > 0.75:
		fill_stylebox.bg_color = Color(0.0, 0.7, 0.0)  # Green for health > 75%
	elif health_percentage > 0.5:
		fill_stylebox.bg_color = Color(1.0, 1.0, 0.0)  # Yellow for health between 50% and 75%
	elif health_percentage > 0.25:
		fill_stylebox.bg_color = Color(1.0, 0.65, 0.0)  # Orange for health between 25% and 50%
	else:
		fill_stylebox.bg_color = Color(1.0, 0.0, 0.0)  # Red for health below 25%


# Function to update the oxygen bar's color based on the player's current oxygen level
func update_oxygen_color() -> void:
	var oxygen_percentage = float(%Player.current_oxygen) / float(%Player.max_oxygen)

	# Get the fill stylebox of the oxygen bar to modify its color
	var fill_stylebox = oxygen_bar.get("theme_override_styles/fill")
	if fill_stylebox == null:
		# If there's no existing style, create a new one
		fill_stylebox = StyleBoxFlat.new()
		oxygen_bar.set("theme_override_styles/fill", fill_stylebox)

	# Set the color of the oxygen bar based on the oxygen percentage:
	if oxygen_percentage > 0.75:
		fill_stylebox.bg_color = Color(0.0, 0.5, 1.0)  # Blue for oxygen > 75%
	elif oxygen_percentage > 0.5:
		fill_stylebox.bg_color = Color(0.0, 1.0, 1.0)  # Cyan for oxygen between 50% and 75%
	elif oxygen_percentage > 0.25:
		fill_stylebox.bg_color = Color(1.0, 1.0, 0.0)  # Yellow for oxygen between 25% and 50%
	else:
		fill_stylebox.bg_color = Color(1.0, 0.0, 0.0)  # Red for oxygen below 25% 


func _on_player_oxygen_changed() -> void:
	pass # Replace with function body.
