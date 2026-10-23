extends Node

@onready var logo_pivot: Node3D = $LogoPivot
@onready var cover: MeshInstance3D = $Cover
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	print("Timer Started")
	await get_tree().create_timer(1.5).timeout
	print("Timer ended")

	cover.transform.origin.y = -1.1

	print("Timer Started")
	await get_tree().create_timer(1.5).timeout
	print("Timer ended")
	
	cover.visible = false
	cover.transform.origin.y = 0.0

	print("Timer Started")
	await get_tree().create_timer(1.5).timeout
	print("Timer ended")

	anim.play("LogoSpin")

	await anim.animation_finished
	
	print("Switching to Main Menu")
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _process(delta: float) -> void:
	if Input.is_anything_pressed():
		print("Switching to Main Menu")
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
