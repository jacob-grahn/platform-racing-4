extends Node2D


var hostname: String = ""
var save_dir: String = "user://editor"
var current_level_name: String = "first"

func get_base_url() -> String:
	if OS.has_feature('web'):
		if !hostname:
			hostname = JavaScriptBridge.eval('window.location.hostname')
			print("Setting base url hostname: ", hostname)
		return "https://" + hostname
		
	if '--local' in OS.get_cmdline_args() || OS.is_debug_build() || OS.get_environment('PR_ENV') == 'local' || OS.has_feature("editor"):
		return 'http://localhost:8080'
		#return 'https://dev.platformracing.com'
	elif '--dev' in OS.get_cmdline_args() || OS.get_environment('PR_ENV') == 'dev':
		return 'https://dev.platformracing.com'
	else:
		return 'https://platformracing.com'

func _get_current_level_name() -> String:
	return current_level_name
	
func _get_level_file_name(level_name: String) -> String:
	return "/" + level_name + ".json"

func _list_saved_levels() -> Array:
	var filenames = []
	var dir = DirAccess.open(save_dir)
	if dir and dir.dir_exists(save_dir):
		dir.list_dir_begin()
		while true:
			var file_name = dir.get_next()
			if file_name == "":
				break
			if file_name.ends_with(".json"):
				filenames.append(file_name.get_basename())
		dir.list_dir_end()
	return filenames

func _set_current_level_name(level_name: String):
	current_level_name = level_name

func _save_to_file(level: Dictionary, level_name: String = current_level_name) -> String:
	if level_name == "":
		return ""
	
	current_level_name = level_name
	var file_name = _get_level_file_name(level_name)
	# ensure directory exists
	if (!DirAccess.dir_exists_absolute(save_dir)):
		DirAccess.make_dir_absolute(save_dir)
	
	var save_file_path: String = save_dir + file_name
	# save level to disk
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	var json_string = JSON.stringify(level)
	var compressed_data = gzip_encode(json_string)
	var encoded_data = Marshalls.raw_to_base64(compressed_data)
	
	file.store_string(json_string)
	file.close()
	return encoded_data
	
func _delete_level(level_name: String = current_level_name) -> void:
	var file_name = _get_level_file_name(level_name)
	var save_file_path: String = save_dir + file_name
	DirAccess.remove_absolute(save_file_path)

func _load_from_file(level_name: String = current_level_name):
	var file_name = _get_level_file_name(level_name)
	var save_file_path: String = save_dir + file_name
	if not FileAccess.file_exists(save_file_path):
		return

	var file = FileAccess.open(save_file_path, FileAccess.READ)
	var level = JSON.parse_string(file.get_as_text())
	file.close()
	
	return level

func set_scene(scene_name: String) -> Node:
	return get_node("/root/Main").set_scene(scene_name)


func to_atlas_coords(block_id: int) -> Vector2i:
	if block_id == 0:
		return Vector2(-1, -1)
	var id = block_id - 1
	var x = id % 10
	var y = id / 10
	return Vector2i(x, y)


func to_block_id(atlas_coords: Vector2i) -> int:
	return (atlas_coords.y * 10) + atlas_coords.x + 1


func to_bitmask_32(num: int) -> int:
	if num < 1 or num > 32:
		return 0 # Return 0 for out of range numbers
	return 1 << (num - 1)


func get_depth(node: Node) -> int:
	if node is Layer:
		return node.depth
	return get_depth(node.get_parent())

func gzip_encode(text: String):
	var gzip = StreamPeerGZIP.new()
	gzip.start_compression()
	gzip.put_data(text.to_utf8_buffer())
	gzip.finish()
	return gzip.get_data(gzip.get_available_bytes())[1]

func gzip_decode(data):
	var gzip = StreamPeerGZIP.new()
	gzip.start_decompression()
	gzip.put_data(data)
	gzip.finish()
	return gzip.get_utf8_string(gzip.get_available_bytes())

func generate_uuidv4() -> String:
	var uuid = []
	for i in range(16):
		uuid.append(randi() % 256)

	uuid[6] = (uuid[6] & 0x0F) | 0x40
	uuid[8] = (uuid[8] & 0x3F) | 0x80
	
	return format_uuid(uuid)

func format_uuid(uuid: Array) -> String:
	return "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x" % uuid
