# Sections of this were coded with AI

extends Control

@onready var camera: Camera2D = $"../../GameNode/Player/Camera2D"
@onready var zoom_slider: VSlider = $ZoomSlider
@onready var conveyor_hover_icon: Sprite2D = $ConveyorHoverIcon
@onready var machine_hover_icon: Sprite2D = $MachineHoverIcon
@onready var game_node: Node2D = $"../../GameNode"
@onready var root_node: Node2D = $"../.."
@onready var canvas_layer: CanvasLayer = $".."
@onready var item_layer: Node2D = $"../../GameNode/Items"
@onready var player: CharacterBody2D = $"../../GameNode/Player"
@onready var pause_screen: Control = $PauseScreen
@onready var deploy_image: TextureRect = $Deployment/DeployImage
@onready var tank_amount_label: Label = $Deployment/TankAmount
@onready var click: AudioStreamPlayer2D = $Click
@onready var war_song: AudioStreamPlayer2D = $WarSong
@onready var deployment_menu: Control = $Deployment
@onready var wave_button: TextureButton = $WaveButton
@onready var start_wave_image: Texture2D = wave_button.texture_normal

const PLAYER_TANK = preload("uid://cddn01b7a7g3j")
const ENEMY_TANK = preload("uid://3ftuqn1ky4pu")
const ITEM = preload("uid://b14uuyn7dc2w4")
const CONVEYOR_TILES: Dictionary = {
	# Top Hub: Counter-Clockwise (CCW)
	"CCW_TOP_LEFT":      0,
	"CCW_TOP_RIGHT":     1,
	"CCW_BOTTOM_LEFT":   4,
	"CCW_BOTTOM_RIGHT":  5,
	
	# Straights
	"STRAIGHT_UP":       2,
	"STRAIGHT_RIGHT":    3,
	"STRAIGHT_DOWN":     7,
	"STRAIGHT_LEFT":     6,
	
	# Bottom Hub: Clockwise (CW)
	"CW_TOP_LEFT":       8,
	"CW_TOP_RIGHT":      9,
	"CW_BOTTOM_LEFT":   12,
	"CW_BOTTOM_RIGHT":  13,
}

const FACTORY_TILES: Dictionary = {
	"Light":        7,
	"Medium":       8,
	"Heavy":        9,
	"Super_Heavy": 10,
}

var deployImages := [
	preload("res://Assets/LightDeploy.png"),
	preload("res://Assets/MediumDeploy.png"),
	preload("res://Assets/HeavyTank.png"),
	preload("res://Assets/SHeavyDeploy.png"),
]

var deployImagesIdx: int = 0

var waveImages := [
	preload("res://Assets/wave1.png"),
	preload("res://Assets/wave2.png"),
	preload("res://Assets/wave3.png"),
	preload("res://Assets/wave4.png"),
	preload("res://Assets/wave5.png"),
]

var waveIdx: int = 0

const ROTATION_ORDER := [2, 3, 7, 6]
var conveyor_rotation_index: int = 0
var factory_rotation_index: int = 7

var is_slider_interacting: bool = false

func _ready() -> void:
	zoom_slider.gui_input.connect(_on_slider_gui_input)


func _on_slider_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_slider_interacting = true
		else:
			is_slider_interacting = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		if Global.hover_icon == "Iron":
			inst(item_layer.get_global_mouse_position(), "Iron")
		elif Global.hover_icon == "Chromium":
			inst(item_layer.get_global_mouse_position(), "Chromium")
	
	if event.is_action_pressed("rotate"):
		if Global.hover_icon is String:
			if check_conveyor(Global.hover_icon) == true:
				conveyor_rotation_index += 1
				
				if conveyor_rotation_index == 4:
					conveyor_rotation_index = 0
				
				var id = ROTATION_ORDER[conveyor_rotation_index]
				
				conveyor_hover_icon.frame = id
				Global.hover_icon = "CONVEYOR_" + CONVEYOR_TILES.find_key(id)
			elif check_factory(Global.hover_icon) == true:
				factory_rotation_index += 1
				
				if factory_rotation_index == 11:
					factory_rotation_index = 7
				
				machine_hover_icon.frame = factory_rotation_index
				Global.hover_icon = "Factory_" + FACTORY_TILES.find_key(factory_rotation_index)


func _process(delta: float) -> void:
	if is_slider_interacting and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_slider_interacting = false
	
	if check_conveyor(Global.hover_icon) == false and conveyor_hover_icon.frame != 0:
		conveyor_hover_icon.frame = 15
	
	if Global.hover_icon == null:
		conveyor_hover_icon.visible = false
		machine_hover_icon.visible = false
	
	if Global.hover_icon == "Miner" or check_factory(Global.hover_icon) == true:
		conveyor_hover_icon.visible = false
		machine_hover_icon.visible = true
	elif Global.hover_icon != null:
		conveyor_hover_icon.visible = true
		machine_hover_icon.visible = false
	
	var zoom_amount = zoom_slider.value
	if zoom_amount >= 1:
		zoom_amount -= 1
		zoom_amount *= 3
		zoom_amount += 1
	camera.zoom = Vector2(zoom_amount, zoom_amount)
	
	machine_hover_icon.global_position = get_global_mouse_position()
	machine_hover_icon.scale = Vector2(4, 4) * Vector2(zoom_amount, zoom_amount)
	
	conveyor_hover_icon.global_position = get_global_mouse_position()
	conveyor_hover_icon.scale = Vector2(4, 4) * Vector2(zoom_amount, zoom_amount)


func _on_conveyor_button_pressed() -> void:
	click.play()
	if check_conveyor(Global.hover_icon) == false:
		Global.hover_icon = "CONVEYOR_" + "STRAIGHT_UP"
		conveyor_hover_icon.frame = 2
	else:
		Global.hover_icon = null


func _on_item_button_pressed() -> void:
	click.play()
	if Global.hover_icon != "Iron":
		Global.hover_icon = "Iron"
	else:
		Global.hover_icon = null


func _on_destroy_button_pressed() -> void:
	click.play()
	if Global.hover_icon != "Destroy":
		Global.hover_icon = "Destroy"
	else:
		Global.hover_icon = null


func _on_miner_button_pressed() -> void:
	click.play()
	if Global.hover_icon != "Miner":
		Global.hover_icon = "Miner"
		machine_hover_icon.frame = 6
	else:
		Global.hover_icon = null


func _on_factory_button_pressed() -> void:
	click.play()
	if check_factory(Global.hover_icon) == false:
		Global.hover_icon = "Factory" + "_Light"
		machine_hover_icon.frame = 7
	else:
		Global.hover_icon = null


func _on_chromium_button_pressed() -> void:
	click.play()
	if Global.hover_icon != "Chromium":
		Global.hover_icon = "Chromium"
	else:
		Global.hover_icon = null


func _on_iron_button_pressed() -> void:
	click.play()
	if Global.hover_icon != "Iron":
		Global.hover_icon = "Iron"
	else:
		Global.hover_icon = null


func inst(pos: Vector2, type: String):
	var instance = ITEM.instantiate()
	var tile_pos = (pos / 64).floor()
	tile_pos = tile_pos * 64 + Vector2(32, 32)
	instance.position = tile_pos
	instance.type = type
	item_layer.add_child(instance)


func check_conveyor(string) -> bool:
	var stringed = str(string)
	var first_letters = stringed.left(8)
	if first_letters == "CONVEYOR":
		return true
	else:
		return false


func check_factory(string) -> bool:
	var stringed = str(string)
	var first_letters = stringed.left(7)
	if first_letters == "Factory":
		return true
	else:
		return false


func _on_enemy_tank_button_pressed() -> void:
	click.play()
	var instance = ENEMY_TANK.instantiate()
	instance.position = player.position + Vector2(2500, 0)
	game_node.add_child(instance)


func _on_final_battle_button_pressed() -> void:
	click.play()
	if not war_song.playing:
		war_song.play()
	
	# Show the current wave and lock the button until it is defeated
	wave_button.texture_normal = waveImages[waveIdx]
	wave_button.disabled = true
	const WAVES_OTHER = [
		{"light": 10, "medium": 8,  "heavy": 0,  "sheavy": 0},
		{"light": 12, "medium": 20, "heavy": 4,  "sheavy": 0},
		{"light": 15, "medium": 25, "heavy": 8,  "sheavy": 1},
		{"light": 15, "medium": 30, "heavy": 15, "sheavy": 3},
		{"light": 20, "medium": 35, "heavy": 20, "sheavy": 8},
	]
	
	
	const WAVES = [
		{"light": 1, "medium": 0,  "heavy": 0,  "sheavy": 0},
		{"light": 1, "medium": 0, "heavy": 0,  "sheavy": 0},
		{"light": 1, "medium": 0, "heavy": 0,  "sheavy": 0},
		{"light": 1, "medium": 0, "heavy": 0, "sheavy": 0},
		{"light": 1, "medium": 0, "heavy": 0, "sheavy": 0},
	]
	const SPAWN_DISTANCE := 2500.0
	const ROW_SPACING := 300.0
	const LANE_SPACING := 400.0
	const TANKS_PER_ROW := 5
	
	var wave = WAVES[waveIdx]
	print("Wave %d incoming!" % (waveIdx + 1))
	
	# Heaviest tanks first so they spawn at the front
	var spawn_list: Array[String] = []
	for type in ["sheavy", "heavy", "medium", "light"]:
		for n in wave[type]:
			spawn_list.append(type)
	
	var wave_tanks: Array = []
	
	for i in spawn_list.size():
		var row := floori(i / float(TANKS_PER_ROW))
		var col := i % TANKS_PER_ROW
		var y_offset := (col - (TANKS_PER_ROW - 1) / 2.0) * LANE_SPACING
		y_offset += randf_range(-80, 80)
		
		var instance = ENEMY_TANK.instantiate()
		instance.tank_type = spawn_list[i]
		instance.position = player.position + Vector2(SPAWN_DISTANCE + row * ROW_SPACING, y_offset)
		game_node.add_child(instance)
		wave_tanks.append(instance)
		
		# Spawn in small batches to avoid a lag spike on big waves
		if i % 10 == 9:
			await get_tree().process_frame
	
	# Wait until every tank in this wave has been destroyed
	while true:
		wave_tanks = wave_tanks.filter(func(t): return is_instance_valid(t) and not t.is_queued_for_deletion())
		if wave_tanks.is_empty():
			break
		await get_tree().create_timer(0.5).timeout
	
	waveIdx += 1
	
	# Last wave beaten, you win
	if waveIdx >= WAVES.size():
		get_tree().change_scene_to_file("res://Scenes/victory_screen.tscn")
		return
	
	# Wave defeated, go back to the start wave button
	wave_button.texture_normal = start_wave_image
	wave_button.disabled = false


func _on_menu_button_pressed() -> void:
	pause_screen.show()
	game_node.process_mode = Node.PROCESS_MODE_DISABLED


func _on_unpause_button_pressed() -> void:
	click.play()
	pause_screen.hide()
	game_node.process_mode = Node.PROCESS_MODE_INHERIT


func _on_save_button_pressed() -> void:
	click.play()
	root_node.save_game()


func _on_main_menu_button_pressed() -> void:
	click.play()
	root_node.save_game()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_left_arrow_button_pressed() -> void:
	click.play()
	deployImagesIdx -= 1
	
	if 0 > deployImagesIdx:
		deployImagesIdx = 3
	
	if deployImagesIdx == 1:
		tank_amount_label.text = str(Global.medium_tanks)
	elif deployImagesIdx == 2:
		tank_amount_label.text = str(Global.heavy_tanks)
	elif deployImagesIdx == 3:
		tank_amount_label.text = str(Global.sheavy_tanks)
	else:
		tank_amount_label.text = str(Global.light_tanks)
	
	deploy_image.texture = deployImages[deployImagesIdx]


func _on_right_arrow_button_pressed() -> void:
	click.play()
	deployImagesIdx += 1
	
	if 3 < deployImagesIdx:
		deployImagesIdx = 0
		
	if deployImagesIdx == 1:
		tank_amount_label.text = str(Global.medium_tanks)
	elif deployImagesIdx == 2:
		tank_amount_label.text = str(Global.heavy_tanks)
	elif deployImagesIdx == 3:
		tank_amount_label.text = str(Global.sheavy_tanks)
	else:
		tank_amount_label.text = str(Global.light_tanks)
	
	deploy_image.texture = deployImages[deployImagesIdx]


func _on_deploy_button_pressed() -> void:
	click.play()
	var instance = PLAYER_TANK.instantiate()
	instance.position = player.position + Vector2(250, 0)
	
	if deployImagesIdx == 0 and Global.light_tanks > 0:
		instance.tank_type = "light"
		Global.light_tanks -= 1
		game_node.add_child(instance)
		tank_amount_label.text = str(Global.light_tanks)
	elif deployImagesIdx == 1 and Global.medium_tanks > 0:
		instance.tank_type = "medium"
		Global.medium_tanks -= 1
		game_node.add_child(instance)
		tank_amount_label.text = str(Global.medium_tanks)
	elif deployImagesIdx == 2 and Global.heavy_tanks > 0:
		instance.tank_type = "heavy"
		Global.heavy_tanks -= 1
		game_node.add_child(instance)
		tank_amount_label.text = str(Global.heavy_tanks)
	elif deployImagesIdx == 3 and Global.sheavy_tanks > 0:
		instance.tank_type = "sheavy"
		Global.sheavy_tanks -= 1
		game_node.add_child(instance)
		tank_amount_label.text = str(Global.sheavy_tanks)


func _on_deploy_menu_button_pressed() -> void:
	if deployment_menu.visible == false:
		deployment_menu.show()
	elif deployment_menu.visible == true:
		deployment_menu.hide()
