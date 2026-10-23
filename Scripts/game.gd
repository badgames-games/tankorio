# All of this was coded with AI

extends Node2D

const ITEM = preload("uid://b14uuyn7dc2w4")

@onready var terrain_layer: TileMapLayer = $GameNode/TerrainLayer
@onready var ore_layer: TileMapLayer = $GameNode/OreLayer
@onready var building_layer: TileMapLayer = $GameNode/BuildingLayer
@onready var player: CharacterBody2D = $GameNode/Player
@onready var machines_node: Node2D = $GameNode/Machines
@onready var items_node: Node2D = $GameNode/Items
@onready var trees_node: Node2D = $GameNode/Trees


func _ready() -> void:
	if SaveManager.is_loading:
		apply_save_data(SaveManager.pending_data)
	
	var timer := Timer.new()
	timer.wait_time = 120.0
	timer.autostart = true
	timer.timeout.connect(save_game)
	add_child(timer)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()


func save_game() -> void:
	var data := {
		"terrain": terrain_layer.tile_map_data,
		"ore": ore_layer.tile_map_data,
		"buildings": building_layer.tile_map_data,
		"player_pos": player.global_position,
		"trees": [],
		"machines": [],
		"items": [],
	}
	
	for tree in trees_node.get_children():
		if not tree.is_queued_for_deletion():
			data["trees"].append({"pos": tree.position, "type": tree.type})
	
	for machine in machines_node.get_children():
		if not machine.is_queued_for_deletion():
			data["machines"].append({"pos": machine.position, "type": machine.type})
	
	for item in items_node.get_children():
		if not item.is_queued_for_deletion():
			data["items"].append({"pos": item.position, "type": item.type})
	
	SaveManager.write_save(data)
	print("Game saved")


func apply_save_data(data: Dictionary) -> void:
	building_layer.tile_map_data = data["buildings"]
	
	for m in data["machines"]:
		building_layer.machine_inst(m["pos"], m["type"])
	
	for i in data["items"]:
		var instance = ITEM.instantiate()
		instance.position = i["pos"]
		instance.type = i["type"]
		items_node.add_child(instance)
	
	player.global_position = data["player_pos"]
