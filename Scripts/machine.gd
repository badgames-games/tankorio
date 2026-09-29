extends Area2D

@onready var ore_layer: TileMapLayer = $"../../OreLayer"
@onready var items_node: Node2D = $"../../Items"

const ITEM = preload("uid://b14uuyn7dc2w4")

var type: String
var efficiency: int = 0


func _ready() -> void:
	if type == "miner":
		var ore_local = ore_layer.to_local(position - Vector2(32, 32))
		var grid_ore_pos = ore_layer.local_to_map(ore_local)
		
		var ore_sources := [
			ore_layer.get_cell_source_id(Vector2i(grid_ore_pos.x, grid_ore_pos.y)),
			ore_layer.get_cell_source_id(Vector2i(grid_ore_pos.x + 1, grid_ore_pos.y)),
			ore_layer.get_cell_source_id(Vector2i(grid_ore_pos.x, grid_ore_pos.y + 1)),
			ore_layer.get_cell_source_id(Vector2i(grid_ore_pos.x + 1, grid_ore_pos.y + 1)),
		]
		
		for v in ore_sources:
			if v == 0:
				efficiency += 1
		
		if efficiency > 0:
			while true:
				await get_tree().create_timer(10 / efficiency).timeout
				item_inst(Vector2(position.x + 32, position.y + 96))
		else:
			return
			

func item_inst(pos: Vector2):
	var instance = ITEM.instantiate()
	instance.position = pos
	items_node.add_child(instance)
