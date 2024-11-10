extends TileMap

class_name TileDetector

# Distinguish terrains via numbers 
enum TerrainType {
	ROCK = 0,
	LAVA = 6,
	ICE = 7,
	STEEL = 8
}

# Custom layer id where terrain types lie
const TERRAIN_ID_LAYER = 0

# Preload a light texture
var light_texture = preload("res://Assets/images/circle_light2.png")

func _ready():
	# Check if the texture loaded correctly
	if light_texture == null:
		print("Error: Failed to load light texture.")
	else:
		pass

	# Get the size of each cell in the tilemap
	var cell_size = tile_set.tile_size  # Access the tile size in Godot 4.x

	# Get all used cells in the entire TileMap
	var used_cells = get_used_cells(0)  # Assuming layer 0, iterate all cells
	
	var lava_cells: Array[Vector2i]
	# Iterate through every tile in the used cells to manually check the ID
	for cell_pos in used_cells:
		var tile_data = get_cell_tile_data(0, cell_pos)  # Using layer 0 for now
		var tile_id = tile_data.get_custom_data_by_layer_id(TERRAIN_ID_LAYER)
		
		 #Check if the tile ID matches the custom tile data ID
		if tile_id == TerrainType.LAVA:
			lava_cells.push_back(cell_pos)
			
	lava_cells.sort()
	
	for n in range(0, lava_cells.size(), 32):
		var cell_pos = lava_cells[n]
		var light_instance = PointLight2D.new()

		# Attach the texture to the light
		light_instance.texture = light_texture
		light_instance.position = map_to_local(cell_pos) # Center the light on the tile

		# Adjust brightness and color for a lava-like effect
		light_instance.energy = 2  # Reduce brightness, try values between 0.1 and 0.5
		light_instance.color = Color8(255, 69, 0, 255)  # Set to a reddish-orange color (RGB: 255, 69, 0)

		# Adjust light properties
		light_instance.blend_mode = Light2D.BLEND_MODE_ADD
		
		add_child(light_instance)
