extends Node
## Manages file operations for the game, such as saving and loading levels.

var save_dir: String = "user://editor"
var current_level_name: String = "first"
var current_level_description: String = ""


func get_current_level_name() -> String:
	return current_level_name


func get_current_level_description() -> String:
	return current_level_description


func get_level_file_name(level_name: String) -> String:
	return "/" + level_name + ".json"

func get_level_description(level_name: String) -> String:
	var file_name := get_level_file_name(level_name)
	var save_file_path: String = save_dir + file_name
	if not FileAccess.file_exists(save_file_path):
		return ""

	var file := FileAccess.open(save_file_path, FileAccess.READ)
	var level: Dictionary = JSON.parse_string(file.get_as_text())
	var description = level.get("description")
	var description_text = str(description)
	if !description:
		return ""
	else:
		return description_text


func list_saved_levels() -> Array:
	var filenames := []
	var dir := DirAccess.open(save_dir)
	if dir and dir.dir_exists(save_dir):
		dir.list_dir_begin()
		while true:
			var file_name := dir.get_next()
			if file_name == "":
				break
			if file_name.ends_with(".json"):
				filenames.append(file_name.get_basename())
		dir.list_dir_end()
	return filenames
	

func set_current_level_name(level_name: String) -> void:
	current_level_name = level_name


func set_current_level_description(level_description: String) -> void:
	current_level_description = level_description


func save_to_file(level: Dictionary, level_name: String) -> String:
	if level_name == "":
		return ""
	
	current_level_name = level_name
	var file_name := get_level_file_name(level_name)
	# ensure directory exists
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_absolute(save_dir)
	
	var save_file_path: String = save_dir + file_name
	# save level to disk
	var file := FileAccess.open(save_file_path, FileAccess.WRITE)
	var json_string := JSON.stringify(level)
	var encoded_data := Marshalls.utf8_to_base64(json_string)
	
	file.store_string(json_string)
	file.close()
	return encoded_data
	

func delete_level(level_name: String = current_level_name) -> void:
	var file_name := get_level_file_name(level_name)
	var save_file_path: String = save_dir + file_name
	DirAccess.remove_absolute(save_file_path)


func load_from_file(level_name: String = current_level_name) -> Dictionary:
	var file_name := get_level_file_name(level_name)
	var save_file_path: String = save_dir + file_name
	if not FileAccess.file_exists(save_file_path):
		return {}

	var file := FileAccess.open(save_file_path, FileAccess.READ)
	var level: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	return level
