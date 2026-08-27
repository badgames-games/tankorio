extends Sprite2D

@onready var building_layer: TileMapLayer = $"../../BuildingLayer"

var direction: Vector2 = Vector2(0, 0)

var conveyor_directions = {
	Vector2i(2, 0): Vector2(0, -1), # UP
	Vector2i(3, 0): Vector2(1, 0),  # RIGHT
	Vector2i(2, 1): Vector2(-1, 0), # LEFT
	Vector2i(3, 1): Vector2(0, 1)   # DOWN
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	conveyor_check()
	position += direction


func conveyor_check() -> void:
	var building_layer_position = building_layer.to_local(position)
	var building_grid_pos = building_layer.local_to_map(building_layer_position)
	var building_source_id = building_layer.get_cell_source_id(building_grid_pos)
	
	if building_source_id != 1:
		direction = Vector2(0, 0)
	
	var building_atlas_coords = building_layer.get_cell_atlas_coords(building_grid_pos)
	
	if conveyor_directions.has(building_atlas_coords):
		direction = conveyor_directions[building_atlas_coords]
		if direction.x != 0:
			position.y = floor(position.y / 64) * 64 + 32
		elif direction.y != 0:
			position.x = floor(position.x / 64) * 64 + 32
	else:
		Vector2(0, 0)
