extends Area2D

@onready var ore_layer: TileMapLayer = $"../../OreLayer"
@onready var items_node: Node2D = $"../../Items"
@onready var input_checker: Area2D = $FactoryParts/InputChecker

const ITEM = preload("uid://b14uuyn7dc2w4")

var type: String
var factory_type: String = "Factory_Light"
var efficiency: int = 0

var deployable_tanks: Array = []

var factory_tank_type := {
	"Factory_Light": "light",
	"Factory_Medium": "medium",
	"Factory_Heavy": "heavy",
	"Factory_Super_Heavy": "sheavy",
}

var factory_steel_cost := {
	"Factory_Light": 4,
	"Factory_Medium": 30,
	"Factory_Heavy": 62,
	"Factory_Super_Heavy": 102,
}

var factory_chromium_cost := {
	"Factory_Light": 2,
	"Factory_Medium": 12,
	"Factory_Heavy": 25,
	"Factory_Super_Heavy": 58,
}


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
			var steel_items: Array = []
			var chromium_items: Array = []
			
			for area in areas:
				print(area)
				var item
				if area.get_child(0) is CollisionShape2D:
					item = area.get_parent()
				elif area.get_child(0) is Sprite2D:
					item = area
				if item.is_in_group("Item"):
					if steel_items.has(item) or chromium_items.has(item):
						continue
					
					# Steel is made from the Iron ore items
					if item.type == "Iron":
						steel_items.append(item)
					elif item.type == "Chromium":
						chromium_items.append(item)
			
			var steel_needed: int = factory_steel_cost[factory_type]
			var chromium_needed: int = factory_chromium_cost[factory_type]
			
			if steel_items.size() >= steel_needed and chromium_items.size() >= chromium_needed:
				for i in steel_needed:
					steel_items[i].queue_free()
				for i in chromium_needed:
					chromium_items[i].queue_free()
				
				deployable_tanks.append(factory_tank_type[factory_type])
				print("Tank created: ", factory_tank_type[factory_type])
			
			await get_tree().create_timer(0.1).timeout

func item_inst(pos: Vector2, ore):
	var instance = ITEM.instantiate()
	instance.position = pos
	instance.type = ore
	items_node.add_child(instance)
