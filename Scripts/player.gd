extends CharacterBody2D

@onready var camera_2d: Camera2D = $Camera2D
@onready var terrain_layer: TileMapLayer = $"../TerrainLayer"
@onready var camera: Camera2D = $Camera2D

const LOWEST_SPEED: float = 100.0

var slow_terrain := [
	Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1), 
	Vector2i(2, 0), Vector2i(2, 1), Vector2i(3, 0), Vector2i(3, 1), 
] 

var very_slow_terrain := [
	Vector2i(0, 2), Vector2i(0, 3), Vector2i(1, 2), Vector2i(1, 3), 
	Vector2i(2, 2), Vector2i(2, 3), Vector2i(3, 2), Vector2i(3, 3), 
]

func _physics_process(delta: float) -> void:
	var moveDir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = moveDir * (LOWEST_SPEED + Global.additional_speed)
	
	check_terrain()
	
	
	if Input.is_action_pressed("sprint"):
		if Global.additional_speed == 100.0:
			Global.additional_speed += 100.0
		elif Global.additional_speed == 200.0:
			Global.additional_speed += 200.0
	
	move_and_slide()
	

func check_terrain() -> void:
	var terrain_player_pos = terrain_layer.to_local(self.global_position)
	var terrain_grid_pos = terrain_layer.local_to_map(terrain_player_pos)
	var terrain_source_id = terrain_layer.get_cell_source_id(terrain_grid_pos)
	
	if terrain_source_id != 1:
		return
	
	var terrain_atlas_coords = terrain_layer.get_cell_atlas_coords(terrain_grid_pos)
	
	if slow_terrain.has(terrain_atlas_coords):
		Global.additional_speed = 100.0
	elif very_slow_terrain.has(terrain_atlas_coords):
		Global.additional_speed = 0.0
	else:
		Global.additional_speed = 200.0
