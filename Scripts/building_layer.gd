extends TileMapLayer

@onready var terrain_layer: TileMapLayer = $"../TerrainLayer"
@onready var ui: Control = $"../CanvasLayer/UI"
@onready var machines_node: Node2D = $"../Machines"
const MACHINE = preload("uid://cp1sy2vv7seqr")

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

var first_click_pos: Vector2
#
## Placed direction -> [offset of the tile BEHIND, {neighbour straight: curve it becomes}]
#const BEHIND_RULES: Dictionary = {
	#"CONVEYOR_STRAIGHT_UP": [Vector2i(0, 1), {
		#"CONVEYOR_STRAIGHT_LEFT": "CONVEYOR_CW_BOTTOM_LEFT",
		#"CONVEYOR_STRAIGHT_RIGHT": "CONVEYOR_CCW_BOTTOM_RIGHT"}],
	#"CONVEYOR_STRAIGHT_DOWN": [Vector2i(0, -1), {
		#"CONVEYOR_STRAIGHT_LEFT": "CONVEYOR_CCW_TOP_LEFT",
		#"CONVEYOR_STRAIGHT_RIGHT": "CONVEYOR_CW_TOP_RIGHT"}],
	#"CONVEYOR_STRAIGHT_LEFT": [Vector2i(1, 0), {
		#"CONVEYOR_STRAIGHT_UP": "CONVEYOR_CCW_TOP_RIGHT",
		#"CONVEYOR_STRAIGHT_DOWN": "CONVEYOR_CW_BOTTOM_RIGHT"}],
	#"CONVEYOR_STRAIGHT_RIGHT": [Vector2i(-1, 0), {
		#"CONVEYOR_STRAIGHT_UP": "CONVEYOR_CW_TOP_LEFT",
		#"CONVEYOR_STRAIGHT_DOWN": "CONVEYOR_CCW_BOTTOM_LEFT"}],
#}
#
## Placed direction -> [offset of the tile in FRONT, {neighbour straight: curve it becomes}]
#const FRONT_RULES: Dictionary = {
	#"CONVEYOR_STRAIGHT_UP": [Vector2i(0, -1), {
		#"CONVEYOR_STRAIGHT_LEFT": "CONVEYOR_CCW_TOP_RIGHT",
		#"CONVEYOR_STRAIGHT_RIGHT": "CONVEYOR_CW_TOP_LEFT"}],
	#"CONVEYOR_STRAIGHT_DOWN": [Vector2i(0, 1), {
		#"CONVEYOR_STRAIGHT_LEFT": "CONVEYOR_CW_BOTTOM_RIGHT",   # your screenshot
		#"CONVEYOR_STRAIGHT_RIGHT": "CONVEYOR_CCW_BOTTOM_LEFT"}],
	#"CONVEYOR_STRAIGHT_LEFT": [Vector2i(-1, 0), {
		#"CONVEYOR_STRAIGHT_UP": "CONVEYOR_CW_BOTTOM_LEFT",
		#"CONVEYOR_STRAIGHT_DOWN": "CONVEYOR_CCW_TOP_LEFT"}],
	#"CONVEYOR_STRAIGHT_RIGHT": [Vector2i(1, 0), {
		#"CONVEYOR_STRAIGHT_UP": "CONVEYOR_CCW_BOTTOM_RIGHT",
		#"CONVEYOR_STRAIGHT_DOWN": "CONVEYOR_CW_TOP_RIGHT"}],
#}
#
#
#func update_neighbor_curves(grid_pos: Vector2i, placed: String) -> void:
	#_apply_rule(BEHIND_RULES, grid_pos, placed)
	#_apply_rule(FRONT_RULES, grid_pos, placed)
#
#
#func _apply_rule(rules: Dictionary, grid_pos: Vector2i, placed: String) -> void:
	#if not rules.has(placed):
		#return
#
	#var offset: Vector2i = rules[placed][0]
	#var results: Dictionary = rules[placed][1]
	#var neighbour := grid_pos + offset
#
	#if get_cell_source_id(neighbour) != 1:
		#return
#
	#var atlas_coords := get_cell_atlas_coords(neighbour)
	#for straight_name in results:
		#if atlas_coords == CONVEYOR_TILES[straight_name]:
			#set_cell(neighbour, 1, CONVEYOR_TILES[results[straight_name]])
			#return
#

func _ready() -> void:
	pass # Replace with function body.


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		first_click_pos = get_global_mouse_position()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("left_click"):
		if ui.is_slider_interacting:
			return
		
		if get_viewport().is_input_handled():
			return
		
		if get_viewport().gui_get_hovered_control() != null:
			return
			
		if Global.hover_icon != null:
			var terrain_mouse = terrain_layer.to_local(get_global_mouse_position())
			var terrain_grid_pos = terrain_layer.local_to_map(terrain_mouse)
			var terrain_source_id = terrain_layer.get_cell_source_id(terrain_grid_pos)
			
			if terrain_source_id != 1: return
			
			var terrain_atlas_coords = terrain_layer.get_cell_atlas_coords(terrain_grid_pos)
			
			if allowed_terrain_atlas_coords.has(terrain_atlas_coords):
				var local_mouse = to_local(get_global_mouse_position())
				var grid_pos = local_to_map(local_mouse)
				var source_id = get_cell_source_id(grid_pos)
				
				if Global.hover_icon == "Destroy":
					var erased_block := false

					if source_id == 0:
						var atlas_coords = get_cell_atlas_coords(grid_pos)

						var block_atlas_origin := Vector2i(12, 0)  # top-left tile of the block in the atlas
						var block_size := Vector2i(2, 2)

						# Which part of the block did we click? (0,0) = top-left ... (1,1) = bottom-right
						var offset = atlas_coords - block_atlas_origin

						if offset.x >= 0 and offset.x < block_size.x and offset.y >= 0 and offset.y < block_size.y:
							var block_origin = grid_pos - offset  # top-left cell of the block on the map
							for x in block_size.x:
								for y in block_size.y:
									erase_cell(block_origin + Vector2i(x, y))
							
							for machine: Area2D in machines_node.get_children():
								if Vector2i((machine.position - Vector2(64, 64)) / 64) == block_origin:
									machine.queue_free()
									continue
							
							erased_block = true

					if not erased_block:
						erase_cell(grid_pos)
				
				if source_id != -1:
					return
				
				match Global.hover_icon:
					"CONVEYOR_STRAIGHT_RIGHT", "CONVEYOR_STRAIGHT_LEFT":
						grid_pos = local_to_map(to_local(Vector2(get_global_mouse_position().x, first_click_pos.y)))
					"CONVEYOR_STRAIGHT_UP", "CONVEYOR_STRAIGHT_DOWN":
						grid_pos = local_to_map(to_local(Vector2(first_click_pos.x, get_global_mouse_position().y)))
					_:
						grid_pos = local_to_map(to_local(get_global_mouse_position()))
				
				if CONVEYOR_TILES.has(Global.hover_icon):
					set_cell(grid_pos, 1, CONVEYOR_TILES[Global.hover_icon])
					
					#update_neighbor_curves(grid_pos, Global.hover_icon)
					#
					#if Global.hover_icon == "CONVEYOR_STRAIGHT_UP":
						#var behind_tile = Vector2i(grid_pos.x, grid_pos.y + 1)
						#if get_cell_source_id(behind_tile) != 1:
							#return
#
						#var atlas_coords = get_cell_atlas_coords(behind_tile)
#
						#if atlas_coords == CONVEYOR_TILES["CONVEYOR_STRAIGHT_LEFT"]:
							#set_cell(behind_tile, 1, CONVEYOR_TILES["CONVEYOR_CW_BOTTOM_LEFT"])
						#elif atlas_coords == CONVEYOR_TILES["CONVEYOR_STRAIGHT_RIGHT"]:
							#set_cell(behind_tile, 1, CONVEYOR_TILES["CONVEYOR_CCW_BOTTOM_RIGHT"])
						#else:
							#return
#
					#if Global.hover_icon == "CONVEYOR_STRAIGHT_DOWN":
						#var behind_tile = Vector2i(grid_pos.x, grid_pos.y - 1)
						#if get_cell_source_id(behind_tile) != 1:
							#return
#
						#var atlas_coords = get_cell_atlas_coords(behind_tile)
#
						#if atlas_coords == CONVEYOR_TILES["CONVEYOR_STRAIGHT_LEFT"]:
							#set_cell(behind_tile, 1, CONVEYOR_TILES["CONVEYOR_CCW_TOP_LEFT"])
						#elif atlas_coords == CONVEYOR_TILES["CONVEYOR_STRAIGHT_RIGHT"]:
							#set_cell(behind_tile, 1, CONVEYOR_TILES["CONVEYOR_CW_TOP_RIGHT"])
						#else:
							#return
#
					#if Global.hover_icon == "CONVEYOR_STRAIGHT_LEFT":
						#var behind_tile = Vector2i(grid_pos.x + 1, grid_pos.y)
						#if get_cell_source_id(behind_tile) != 1:
							#return
#
						#var atlas_coords = get_cell_atlas_coords(behind_tile)
#
						#if atlas_coords == CONVEYOR_TILES["CONVEYOR_STRAIGHT_UP"]:
							#set_cell(behind_tile, 1, CONVEYOR_TILES["CONVEYOR_CCW_TOP_RIGHT"])
						#elif atlas_coords == CONVEYOR_TILES["CONVEYOR_STRAIGHT_DOWN"]:
							#set_cell(behind_tile, 1, CONVEYOR_TILES["CONVEYOR_CW_BOTTOM_RIGHT"])
						#else:
							#return
#
					#if Global.hover_icon == "CONVEYOR_STRAIGHT_RIGHT":
						#var behind_tile = Vector2i(grid_pos.x - 1, grid_pos.y)
						#if get_cell_source_id(behind_tile) != 1:
							#return
#
						#var atlas_coords = get_cell_atlas_coords(behind_tile)
#
						#if atlas_coords == CONVEYOR_TILES["CONVEYOR_STRAIGHT_UP"]:
							#set_cell(behind_tile, 1, CONVEYOR_TILES["CONVEYOR_CW_TOP_LEFT"])
						#elif atlas_coords == CONVEYOR_TILES["CONVEYOR_STRAIGHT_DOWN"]:
							#set_cell(behind_tile, 1, CONVEYOR_TILES["CONVEYOR_CCW_BOTTOM_LEFT"])
						#else:
							#return
					
				elif Global.hover_icon == "Miner":
					if source_id == -1:
						if get_cell_source_id(Vector2i(grid_pos.x + 1, grid_pos.y)) == -1:
							if get_cell_source_id(Vector2i(grid_pos.x, grid_pos.y + 1)) == -1:
								if get_cell_source_id(Vector2i(grid_pos.x + 1, grid_pos.y + 1)) == -1:
									set_cell(grid_pos, 0, Vector2i(12, 0))
									set_cell(grid_pos + Vector2i(1, 0), 0, Vector2i(13, 0))
									set_cell(grid_pos + Vector2i(0, 1), 0, Vector2i(12, 1))
									set_cell(grid_pos + Vector2i(1, 1), 0, Vector2i(13, 1))
									
									machine_inst((get_global_mouse_position() / 64).ceil() * 64, "miner")


func machine_inst(pos: Vector2, type: String):
	var instance = MACHINE.instantiate()
	instance.position = pos
	instance.type = type
	machines_node.add_child(instance)
