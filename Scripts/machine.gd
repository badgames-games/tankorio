extends Area2D

@onready var ore_layer: TileMapLayer = $"../../OreLayer"
@onready var items_node: Node2D = $"../../Items"
@onready var input_checker: Area2D = $FactoryParts/InputChecker

const ITEM = preload("uid://b14uuyn7dc2w4")

var type: String
var efficiency: int = 0


func _ready() -> void:
	if type == "miner":
		$FactoryParts.queue_free()
		
		var ore_local = ore_layer.to_local(position - Vector2(32, 32))
		var grid_ore_pos = ore_layer.local_to_map(ore_local)
		
		var ore_sources := [
			ore_layer.get_cell_source_id(Vector2i(grid_ore_pos.x, grid_ore_pos.y)),
			ore_layer.get_cell_source_id(Vector2i(grid_ore_pos.x + 1, grid_ore_pos.y)),
			ore_layer.get_cell_source_id(Vector2i(grid_ore_pos.x, grid_ore_pos.y + 1)),
			ore_layer.get_cell_source_id(Vector2i(grid_ore_pos.x + 1, grid_ore_pos.y + 1)),
		]
		
		var atlas_coords := [
			ore_layer.get_cell_atlas_coords(Vector2i(grid_ore_pos.x, grid_ore_pos.y)),
			ore_layer.get_cell_atlas_coords(Vector2i(grid_ore_pos.x + 1, grid_ore_pos.y)),
			ore_layer.get_cell_atlas_coords(Vector2i(grid_ore_pos.x, grid_ore_pos.y + 1)),
			ore_layer.get_cell_atlas_coords(Vector2i(grid_ore_pos.x + 1, grid_ore_pos.y + 1)),
		]
		
		var ore: String
		
		for i in ore_sources.size():
			if ore_sources[i] == 0:
				efficiency += 1
				if atlas_coords[i].y in [0, 1]:
					ore = "Iron"
				elif atlas_coords[i].y in [2, 3]:
					ore = "Chromium"
		
		if efficiency > 0:
			while true:
				await get_tree().create_timer(10 / efficiency).timeout
				item_inst(Vector2(position.x + 32, position.y + 96), ore)
		else:
			return
	
	elif type == "factory":
		while true:
			var areas = input_checker.get_overlapping_areas()
			var items: Array = []
			var ores: Array = []
			
			for area in areas:
				print(area)
				var item
				if area.get_child(0) is CollisionShape2D:
					item = area.get_parent()
				elif area.get_child(0) is Sprite2D:
					item = area
				if item.is_in_group("Item"):
					var ore = item.type
					ores.append(ore)
					items.append(item)
			
			if ores.has("Chromium") and ores.has("Iron"):
				for i in items:
					i.queue_free()
				print("Tank created")
				
			await get_tree().create_timer(0.1).timeout

func item_inst(pos: Vector2, ore):
	var instance = ITEM.instantiate()
	instance.position = pos
	instance.type = ore
	items_node.add_child(instance)
