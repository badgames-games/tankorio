extends Area2D

@onready var building_layer: TileMapLayer = $"../../BuildingLayer"
@onready var bumper_detector: Area2D = $BumperDetector
@onready var bumper: CollisionShape2D = $BumperDetector/Bumper

var direction: Vector2 = Vector2(0, 0)
var overlapping: bool = false

var conveyor_directions = {
	Vector2i(2, 0): Vector2(0, -1), # UP
	Vector2i(3, 0): Vector2(1, 0),  # RIGHT
	Vector2i(2, 1): Vector2(-1, 0), # LEFT
	Vector2i(3, 1): Vector2(0, 1)   # DOWN
}

func _process(delta: float) -> void:
	conveyor_check()
	position += direction


func conveyor_check() -> void:
	var building_layer_position = building_layer.to_local(global_position)
	var building_grid_pos = building_layer.local_to_map(building_layer_position)
	var building_source_id = building_layer.get_cell_source_id(building_grid_pos)

	if building_source_id != 1:
		direction = Vector2(0, 0)
		return

	var building_atlas_coords = building_layer.get_cell_atlas_coords(building_grid_pos)

	if not conveyor_directions.has(building_atlas_coords):
		direction = Vector2(0, 0)
		return

	if overlapping:
		direction = Vector2(0, 0)
		return

	var tile_center_x: float = floor(position.x / 64.0) * 64.0 + 32.0
	var tile_center_y: float = floor(position.y / 64.0) * 64.0 + 32.0
	var turn_threshold: float = 4.0

	var queued_direction = conveyor_directions[building_atlas_coords]

	if queued_direction.x != 0:
		if abs(position.y - tile_center_y) <= turn_threshold:
			position.y = tile_center_y
			direction = queued_direction
			bumper.position = Vector2(queued_direction.x * 9.0, 0.0)
		else:
			# Not vertically centered yet - nudge toward center instead of freezing
			direction = Vector2(0, sign(tile_center_y - position.y))
	elif queued_direction.y != 0:
		if abs(position.x - tile_center_x) <= turn_threshold:
			position.x = tile_center_x
			direction = queued_direction
			bumper.position = Vector2(0.0, queued_direction.y * 9.0)
		else:
			# Not horizontally centered yet - nudge toward center instead of freezing
			direction = Vector2(sign(tile_center_x - position.x), 0)


func _physics_process(delta: float) -> void:
	var overlapping_layers = bumper_detector.get_overlapping_areas()
	overlapping = overlapping_layers.size() > 0
