extends TileMapLayer

@onready var terrain_layer: TileMapLayer = $"../TerrainLayer"

var map_size := Vector2(65536, 65536)

var allowed_terrain_atlas_coords := [
	Vector2i(0, 4), Vector2i(1, 4), Vector2i(0, 5), Vector2i(1, 5), # Sand
	Vector2i(2, 4), Vector2i(3, 4), Vector2i(2, 5), Vector2i(3, 5), # Grass
]

func _ready() -> void:
	await get_tree().process_frame
	position =- Vector2(map_size / 2)
	
	var ore_noise := FastNoiseLite.new()
	ore_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	ore_noise.seed = randi()
	ore_noise.frequency = 0.007
	
	
	for x in map_size.x / 64:
		for y in map_size.y / 64:
			var o: float = ore_noise.get_noise_2d(x, y)
			
			var iron_ore := Vector2i(randi_range(0, 1), randi_range(0, 1))
			var chromium_ore := Vector2i(randi_range(0, 1), randi_range(2, 3))
			
			var pos = Vector2(x, y) - map_size / 128
			
			var terrain_pos = terrain_layer.to_local(pos * 64)
			var terrain_grid_pos = terrain_layer.local_to_map(terrain_pos)
			var terrain_source_id = terrain_layer.get_cell_source_id(terrain_grid_pos)
			
			if terrain_source_id != 1:
				continue
			
			var terrain_atlas_coords = terrain_layer.get_cell_atlas_coords(terrain_grid_pos)
			
			if allowed_terrain_atlas_coords.has(terrain_atlas_coords):
				if o > 0.4:
					set_cell(Vector2i(x, y), 0, iron_ore)
				elif o < -0.4:
					set_cell(Vector2i(x, y), 0, chromium_ore)
