extends Control

@onready var main_theme: AudioStreamPlayer2D = $MainTheme

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_new_save_pressed() -> void:
	SaveManager.new_save()
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_load_save_pressed() -> void:
	SaveManager.load_from_disk()
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _ready() -> void:
	main_theme.play()
