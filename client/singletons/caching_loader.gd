extends Node

const CACHE_DIR = "user://cache"
var _memory = {}


func load_file(url: String) -> PackedByteArray:
	var bytes: PackedByteArray

	# In memory?
	if url in _memory:
		return _memory[url]
	
	# In disk cache?
	if _is_cached(url):
		bytes = _load_from_cache(url)
		_memory[url] = bytes
		return bytes
	
	# Download!
	print("CachingLoader - Downloading: %s" % url)
	bytes = await _load_from_web(url)
	if bytes.size() > 0:
		_add_to_cache(url, bytes)
	_memory[url] = bytes
	return bytes


func load_texture(url: String) -> Texture2D:
	var bytes = await load_file(url)
	var image = Image.new()
	if url.ends_with(".jpg"):
		image.load_jpg_from_buffer(bytes)
	elif url.ends_with(".png"):
		image.load_png_from_buffer(bytes)
	elif url.ends_with(".webp"):
		image.load_webp_from_buffer(bytes)
	else:
		print("CachingLoader - Unknown image format: %s" % url)
		return null
	var texture: Texture2D = ImageTexture.create_from_image(image)
	return texture


func inject(url: String, value) -> void:
	_memory[url] = value


func _is_cached(url: String) -> bool:
	var url_hash = url.md5_text()
	var path = CACHE_DIR.path_join(url_hash)
	return FileAccess.file_exists(path)


func _load_from_cache(url: String) -> PackedByteArray:
	var url_hash = url.md5_text()
	var path = CACHE_DIR.path_join(url_hash)
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(path)
	return bytes


func _add_to_cache(url: String, bytes: PackedByteArray) -> void:
	# Create cache dir if it doesn't exist
	DirAccess.make_dir_absolute(CACHE_DIR)

	# Save to cache
	var url_hash = url.md5_text()
	var path = CACHE_DIR.path_join(url_hash)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(bytes)
	file.close()


func _load_from_web(url: String) -> PackedByteArray:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	var error = http_request.request(url)
	if error != OK:
		print("CachingLoader - Error fetching %s: %s" % [url, error])
		http_request.queue_free()
		return []
	
	var result = await http_request.request_completed
	var response_code = result[1]
	var body = result[3]
	http_request.queue_free()

	if response_code != 200:
		print(url + " couldn't be downloaded. Response code: " + str(response_code))
		return []

	return body
