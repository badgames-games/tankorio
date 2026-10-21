extends Control


func _on_play_button_pressed() -> void:
	SaveManager.load_from_disk()
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_settings_button_pressed() -> void:
	mega_crash_function()


func _on_credits_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/tank_test_scene.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func mega_crash_function():
	var crash_message = "Initiating intentional stack overflow crash..."
	print(crash_message)
	
	mega_crash_function()


func _on_new_save_pressed() -> void:
	SaveManager.new_save()
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
