extends TileMapLayer

@onready var terrain_layer: TileMapLayer = $"../TerrainLayer"

var allowed_terrain_atlas_coords := [
	Vector2i(0, 4), Vector2i(1, 4), Vector2i(0, 5), Vector2i(1, 5), # Sand
	Vector2i(2, 4), Vector2i(3, 4), Vector2i(2, 5), Vector2i(3, 5), # Grass
]

const CONVEYOR_TILES: Dictionary = {
	# Top Hub: Counter-Clockwise (CCW)
	"CONVEYOR_CCW_TOP_LEFT":     Vector2i(0, 0), # ID 0
	"CONVEYOR_CCW_TOP_RIGHT":    Vector2i(1, 0), # ID 1
	"CONVEYOR_CCW_BOTTOM_LEFT":  Vector2i(0, 1), # ID 4
	"CONVEYOR_CCW_BOTTOM_RIGHT": Vector2i(1, 1), # ID 5
	
	# Straights
	"CONVEYOR_STRAIGHT_UP":      Vector2i(2, 0), # ID 2
	"CONVEYOR_STRAIGHT_RIGHT":   Vector2i(3, 0), # ID 3
	"CONVEYOR_STRAIGHT_DOWN":    Vector2i(3, 1), # ID 7
	"CONVEYOR_STRAIGHT_LEFT":    Vector2i(2, 1), # ID 6
	
	# Bottom Hub: Clockwise (CW)
	"CONVEYOR_CW_TOP_LEFT":      Vector2i(0, 2), # ID 8
	"CONVEYOR_CW_TOP_RIGHT":     Vector2i(1, 2), # ID 9
	"CONVEYOR_CW_BOTTOM_LEFT":   Vector2i(0, 3), # ID 10
	"CONVEYOR_CW_BOTTOM_RIGHT":  Vector2i(1, 3), # ID 11
}


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("left_click"):
		if Global.hover_icon != null:
			var terrain_mouse = terrain_layer.to_local(get_global_mouse_position())
			var terrain_grid_pos = terrain_layer.local_to_map(terrain_mouse)
			var terrain_source_id = terrain_layer.get_cell_source_id(terrain_grid_pos)
			
			if terrain_source_id != 1:
				return
			
			var terrain_atlas_coords = terrain_layer.get_cell_atlas_coords(terrain_grid_pos)
			
			if allowed_terrain_atlas_coords.has(terrain_atlas_coords):
				var mouse_pos = to_local(get_global_mouse_position())
				var grid_pos = local_to_map(mouse_pos)
				
				if CONVEYOR_TILES.has(Global.hover_icon):
					print(Global.hover_icon)
					set_cell(grid_pos, 1, CONVEYOR_TILES[Global.hover_icon])
				elif Global.hover_icon == "Destroy":
					erase_cell(grid_pos)
