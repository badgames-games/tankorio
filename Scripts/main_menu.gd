extends Control


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_settings_button_pressed() -> void:
	mega_crash_function()


func _on_credits_button_pressed() -> void:
	mega_crash_function()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func mega_crash_function():
	# Generates a quick error string to help identify the crash in logs
	var crash_message = "Initiating intentional stack overflow crash..."
	print(crash_message)
	
	# Call itself infinitely; Godot will crash once it hits the stack limit
	mega_crash_function()
