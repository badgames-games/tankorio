extends Control

@onready var song: AudioStreamPlayer2D = $Song

func _ready() -> void:
	song.play()


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
