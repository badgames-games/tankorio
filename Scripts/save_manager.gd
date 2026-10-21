extends Node

const SAVE_PATH := "user://savegame.save"

var is_loading: bool = false
var pending_data: Dictionary = {}


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func new_save() -> void:
	is_loading = false
	pending_data = {}
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)


func write_save(data: Dictionary) -> void:
	var tmp_path := SAVE_PATH + ".tmp"
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file: " + str(FileAccess.get_open_error()))
		return
	file.store_var(data)
	file.close()
	DirAccess.rename_absolute(tmp_path, SAVE_PATH)


func load_from_disk() -> bool:
	if not has_save():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var data = file.get_var()
	file.close()
	if typeof(data) != TYPE_DICTIONARY:
		return false
	
	pending_data = data
	is_loading = true
	return true
