extends Control

@onready var camera: Camera2D = $"../../Player/Camera2D"
@onready var zoom_slider: VSlider = $ZoomSlider
@onready var hover_icon: TextureRect = $HoverIcon
@onready var game_node: Node2D = $"../.."
@onready var canvas_layer: CanvasLayer = $".."

const CONVEYER_TEMP_ICON = preload("uid://cam6e3k3gppqa")
const IRON_TEMP_ICON = preload("uid://cn3pnx4veuwou")
const BROKEN_TEMP_ICON = preload("uid://dwryli2eikleq")

var item_selected: bool = false
var hover_icon_scale: Vector2 = Vector2(1, 1)


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	var zoom_amount = zoom_slider.value
	if zoom_amount >= 1:
		zoom_amount -= 1
		zoom_amount *= 3
		zoom_amount += 1
	camera.zoom = Vector2(zoom_amount, zoom_amount)
	
	hover_icon.global_position = get_global_mouse_position() - Vector2(32, 32) * Vector2(zoom_amount, zoom_amount)
	hover_icon.scale = Vector2(0.256, 0.256) * Vector2(zoom_amount, zoom_amount)


func _on_conveyor_button_pressed() -> void:
	if item_selected == false:
		hover_icon.texture = CONVEYER_TEMP_ICON
		Global.hover_icon = "Conveyor_Belt"
		hover_icon.scale = hover_icon_scale
		item_selected = true
	else:
		hover_icon.texture = null
		Global.hover_icon = null
		hover_icon.scale = hover_icon_scale
		item_selected = false


func _on_item_button_pressed() -> void:
	if item_selected == false:
		hover_icon.texture = IRON_TEMP_ICON
		Global.hover_icon = "Iron"
		hover_icon.scale = hover_icon_scale
		item_selected = true
	else:
		hover_icon.texture = null
		Global.hover_icon = null
		hover_icon.scale = hover_icon_scale
		item_selected = false


func _on_destroy_button_pressed() -> void:
	if item_selected == false:
		hover_icon.texture = BROKEN_TEMP_ICON
		Global.hover_icon = "Destroy"
		hover_icon.scale = hover_icon_scale
		item_selected = true
	else:
		hover_icon.texture = null
		Global.hover_icon = null
		hover_icon.scale = hover_icon_scale
		item_selected = false
