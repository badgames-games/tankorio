# Sections of this were coded with AI

extends Area2D

@onready var ore_layer: TileMapLayer = $"../../OreLayer"
@onready var items_node: Node2D = $"../../Items"
@onready var input_checker: Area2D = $FactoryParts/InputChecker

const ITEM = preload("uid://b14uuyn7dc2w4")

var type: String
var factory_type: String = "Factory_Light"
var efficiency: int = 0

var steel_stored: int = 0
var chromium_stored: int = 0

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
			var counted_items: Array = []
			
			for area in areas:
				var item
				if area.get_child(0) is CollisionShape2D:
					item = area.get_parent()
				elif area.get_child(0) is Sprite2D:
					item = area
				if item.is_in_group("Item"):
					if counted_items.has(item):
						continue
					counted_items.append(item)
					
					# Steel is made from the Iron ore items
					if item.type == "Iron":
						steel_stored += 1
						item.queue_free()
					elif item.type == "Chromium":
						chromium_stored += 1
						item.queue_free()
			
			var steel_needed: int = factory_steel_cost[factory_type]
			var chromium_needed: int = factory_chromium_cost[factory_type]
			
			while steel_stored >= steel_needed and chromium_stored >= chromium_needed:
				steel_stored -= steel_needed
				chromium_stored -= chromium_needed
				
				match factory_tank_type[factory_type]:
					"light":
						Global.light_tanks += 1
					"medium":
						Global.medium_tanks += 1
					"heavy":
						Global.heavy_tanks += 1
					"sheavy":
						Global.sheavy_tanks += 1
				
				print("Tank created: ", factory_tank_type[factory_type])
			
			await get_tree().create_timer(0.1).timeout


func item_inst(pos: Vector2, ore):
	var instance = ITEM.instantiate()
	instance.position = pos
	instance.type = ore
	items_node.add_child(instance)
