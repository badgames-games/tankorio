extends Control

@onready var camera: Camera2D = $"../../Player/Camera2D"
@onready var zoom_slider: VSlider = $ZoomSlider
@onready var hover_icon: Sprite2D = $HoverIcon
@onready var game_node: Node2D = $"../.."
@onready var canvas_layer: CanvasLayer = $".."
@onready var item_layer: Node2D = $"../../Items"


const IRON = preload("uid://b14uuyn7dc2w4")
const CONVEYOR_TILES: Dictionary = {
	# Top Hub: Counter-Clockwise (CCW)
	"CCW_TOP_LEFT":     0,
	"CCW_TOP_RIGHT":    1,
	"CCW_BOTTOM_LEFT":  4,
	"CCW_BOTTOM_RIGHT": 5,
	
	# Straights
	"STRAIGHT_UP":      2,
	"STRAIGHT_RIGHT":   3,
	"STRAIGHT_DOWN":    7,
	"STRAIGHT_LEFT":    6,
	
	# Bottom Hub: Clockwise (CW)
	"CW_TOP_LEFT":      8,
	"CW_TOP_RIGHT":     9,
	"CW_BOTTOM_LEFT":   12,
	"CW_BOTTOM_RIGHT":  13,
}

const ROTATION_ORDER := [2, 3, 7, 6]
var rotation_order_index: int = 0


func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		if Global.hover_icon == "Iron":
			inst(item_layer.get_global_mouse_position())
	
	if event.is_action_pressed("rotate"):
		if Global.hover_icon is String:
			if check_conveyor(Global.hover_icon) == true:
				rotation_order_index += 1
				
				if rotation_order_index == 4:
					rotation_order_index = 0
				
				var id = ROTATION_ORDER[rotation_order_index]
				
				hover_icon.frame = id
				print("Rotated to:" + "CONVEYOR_" + CONVEYOR_TILES.find_key(id))
				Global.hover_icon = "CONVEYOR_" + CONVEYOR_TILES.find_key(id)


func _process(delta: float) -> void:
	if check_conveyor(Global.hover_icon) == false and hover_icon.frame != 0:
		hover_icon.frame = 0
	
	if Global.hover_icon != null:
		hover_icon.visible = true
	else:
		hover_icon.visible = false
	
	var zoom_amount = zoom_slider.value
	if zoom_amount >= 1:
		zoom_amount -= 1
		zoom_amount *= 3
		zoom_amount += 1
	camera.zoom = Vector2(zoom_amount, zoom_amount)
	
	hover_icon.global_position = get_global_mouse_position()
	hover_icon.scale = Vector2(4, 4) * Vector2(zoom_amount, zoom_amount)


func _on_conveyor_button_pressed() -> void:
	if check_conveyor(Global.hover_icon) == false:
		Global.hover_icon = "CONVEYOR_" + "STRAIGHT_UP"
		hover_icon.frame = 2
	else:
		Global.hover_icon = null

func _on_item_button_pressed() -> void:
	if Global.hover_icon != "Iron":
		Global.hover_icon = "Iron"
	else:
		Global.hover_icon = null


func _on_destroy_button_pressed() -> void:
	if Global.hover_icon != "Destroy":
		Global.hover_icon = "Destroy"
	else:
		Global.hover_icon = null


func inst(pos: Vector2):
	var instance = IRON.instantiate()
	var tile_pos = (pos / 64).floor()
	tile_pos = tile_pos * 64 + Vector2(32, 32)
	instance.position = tile_pos
	item_layer.add_child(instance)


func check_conveyor(string) -> bool:
	var stringed = str(string)
	var first_letters = stringed.left(8)
	if first_letters == "CONVEYOR":
		return true
	else:
		return false
