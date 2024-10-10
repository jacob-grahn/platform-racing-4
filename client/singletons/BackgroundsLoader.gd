extends Node


#const BASE_URL = "https://files.platformracing.com/backgrounds"
const BACKGROUNDS_FOLDER = "res://backgrounds"
const VALID_EXTENSIONS = ['.jpg']

var no_background = Texture2D.new()
var cache = {}
var ids = []


func _ready() -> void:
	_load_background_ids()
	if ids.size() == 0:
		push_warning("No backgrounds loaded!")

func _load_background_ids() -> void:
	
	var dir = DirAccess.open(BACKGROUNDS_FOLDER)
	
	if !dir:
		print("Error loading background IDs: %s" % error_string(DirAccess.get_open_error()))
		return
	
	dir.list_dir_begin()
	
	var file_name = dir.get_next()
	
	while file_name != "":
		
		if VALID_EXTENSIONS.any(file_name.ends_with):
			ids.append(file_name)
		
		if !dir.current_is_dir():
			file_name = dir.get_next()


func load_background(id: String) -> Texture2D:
	
	if id in cache:
		return cache[id]
	
	var path = BACKGROUNDS_FOLDER.path_join(id)
	
	if !FileAccess.file_exists(path):
		push_error("No background with id '%s'" % id)
		return no_background
	
	var image = Image.load_from_file(path)
	if image == null: # In this case an error is logged to console automatically.
		return no_background
	
	var texture = ImageTexture.create_from_image(image)
	cache[id] = texture
	
	return texture

func load_first_background() -> Texture2D:
	return load_background(ids[0])
