# This script was made fully by AI

extends Node

const SAVE_PATH := "user://savegame.save"
const DEFAULT_TANKS := 10

var is_loading: bool = false
var pending_data: Dictionary = {}


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


# Wipes the existing save and prepares a fresh world
func new_save() -> void:
	is_loading = false
	pending_data = {}
	_reset_tanks()
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)


func write_save(data: Dictionary) -> void:
	# Tank counts live in Global, so grab them here and add them to the save
	data["tanks"] = {
		"light": Global.light_tanks,
		"medium": Global.medium_tanks,
		"heavy": Global.heavy_tanks,
		"sheavy": Global.sheavy_tanks,
	}
	
	var tmp_path := SAVE_PATH + ".tmp"
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file: " + str(FileAccess.get_open_error()))
		return
	file.store_var(data)
	file.close()
	DirAccess.rename_absolute(tmp_path, SAVE_PATH)


# Returns false if there is no valid save
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
	_apply_tanks(data)
	return true


func _apply_tanks(data: Dictionary) -> void:
	# Saves made before tanks were added won't have this key, so use defaults
	var tanks: Dictionary = data.get("tanks", {})
	Global.light_tanks = tanks.get("light", DEFAULT_TANKS)
	Global.medium_tanks = tanks.get("medium", DEFAULT_TANKS)
	Global.heavy_tanks = tanks.get("heavy", DEFAULT_TANKS)
	Global.sheavy_tanks = tanks.get("sheavy", DEFAULT_TANKS)


func _reset_tanks() -> void:
	Global.light_tanks = DEFAULT_TANKS
	Global.medium_tanks = DEFAULT_TANKS
	Global.heavy_tanks = DEFAULT_TANKS
	Global.sheavy_tanks = DEFAULT_TANKS
