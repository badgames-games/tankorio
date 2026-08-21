extends TileMapLayer

@onready var terrain_layer: TileMapLayer = $"../TerrainLayer"

var allowed_terrain_atlas_coords := [
	Vector2i(0, 4), Vector2i(1, 4), Vector2i(0, 5), Vector2i(1, 5), # Sand
	Vector2i(2, 4), Vector2i(3, 4), Vector2i(2, 5), Vector2i(3, 5), # Grass
]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		if Global.hover_icon != null:
			var terrain_mouse = terrain_layer.to_local(get_global_mouse_position())
			var terrain_grid_pos = terrain_layer.local_to_map(terrain_mouse)
			var terrain_source_id = terrain_layer.get_cell_source_id(terrain_grid_pos)
			
			if terrain_source_id != 1:
				return
			
			var terrain_atlas_coords = terrain_layer.get_cell_atlas_coords(terrain_grid_pos)
			
			if allowed_terrain_atlas_coords.has(terrain_atlas_coords):
				if Global.hover_icon == "Conveyor_Belt":
					var mouse_pos = to_local(get_global_mouse_position())
					var grid_pos = local_to_map(mouse_pos)
					
					set_cell(grid_pos, 0, Vector2i(0, 8))


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
