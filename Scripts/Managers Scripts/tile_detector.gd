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
	var used_cells = get_used_cells(0)
	var lava_cells: Array[Vector2i]
	
	# Iterate through every tile in the used cells to manually check the ID
	for cell_pos in used_cells:
		var tile_data = get_cell_tile_data(0, cell_pos)  # Using layer 0 for now
		var tile_id = tile_data.get_custom_data_by_layer_id(TERRAIN_ID_LAYER)
		
		# Check if the tile ID matches the custom tile data ID
		if tile_id == TerrainType.LAVA:
			lava_cells.push_back(cell_pos)
	
	# Sort in order of appearance, then add huge lights every couple of tiles
	# Kinda hacky but avoids Godot's limit without introducing children stuff
	lava_cells.sort()
	for n in range(0, lava_cells.size(), 32):
		var cell_pos = lava_cells[n]
		var light_instance = PointLight2D.new()

		# Attach the texture to the light
		light_instance.texture = light_texture
		light_instance.position = map_to_local(cell_pos)

		# Adjust brightness and color for a lava-like effect
		light_instance.energy = 2.5
		light_instance.color = Color8(255, 69, 0, 255)
		light_instance.blend_mode = Light2D.BLEND_MODE_ADD
		
		add_child(light_instance)


func _physics_process(_delta: float) -> void:
	handle_player_on_ice()


func handle_player_on_ice():
	var player_pos : Vector2 = %Player.global_position
	var local_player_pos : Vector2 = to_local(player_pos)
	var curr_tile_pos : Vector2i = local_to_map(local_player_pos)
	var curr_tile_data : TileData = get_cell_tile_data(0, curr_tile_pos)

	if curr_tile_data:
		var curr_tile_id = curr_tile_data.get_custom_data_by_layer_id(TileDetector.TERRAIN_ID_LAYER)
		
		# We can change this to have player track current tile
		# then player makes decisions based off tile, if we really wanted to
		%Player.stepping_tile = curr_tile_id
