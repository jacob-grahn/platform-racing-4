extends Node


const BackgroundsCacheFolderPath = "user://backgrounds"
const BackgroundsBaseUrl = "https://files.platformracing.com/backgrounds"
const VendorBackgroundIds = ["field", "desert", "dots", "generic", "lake", "skyscraper", "space"]

var _fallback = load("res://pages/game/bg-1.jpg")
var _backgrounds = {}


func _ready():
	
	# Make sure backgrounds folder exists
	DirAccess.make_dir_recursive_absolute(BackgroundsCacheFolderPath)
	
	_print("_ready", "Loading backgrounds...")
	var time_started = Time.get_ticks_usec()
	await _load_vendor_backgrounds()
	var time_elapsed = (Time.get_ticks_usec() - time_started) / 1000.0
	_print("_ready", "%s backgrounds Loaded (%sms)" % [_backgrounds.size(), time_elapsed])


func get_ids() -> Array:
	return _backgrounds.keys()

func get_background(id: String) -> Texture2D:
	
	if id == "":
		return _fallback
	
	# In memory?
	if id in _backgrounds:
		return _backgrounds[id]
	
	# In cache?
	if _is_cached(id):
		_load_background_from_cache(id)
		return _backgrounds[id]
	
	# Download!
	var url = BackgroundsBaseUrl.path_join(id + ".jpg")
	_print("get_background", "Downloading background: %s (%s)" % [id, url])
	var response = await _request(url)
	_load_background_from_response(id, response)
	return _backgrounds[id]


func _load_vendor_backgrounds() -> void:
	
	var cached_ids = []
	var missing_ids = []
	
	for id in VendorBackgroundIds:
		if _is_cached(id):
			cached_ids.append(id)
		else:
			missing_ids.append(id)
	
	# Load cached
	if cached_ids.size() > 0:
		
		var task = func(index: int):
			_load_background_from_cache(cached_ids[index])
		
		await AsyncWorkerThreadPool.add_group_task(task, cached_ids.size())
	
	# Download missing
	if missing_ids.size() > 0:
		await _download_backgrounds(missing_ids)

func _download_backgrounds(ids: Array) -> void:
	
	var responses_signal = AsyncWorkerThreadPool.SignalEmitter.new()
	var responses = []
	
	var on_response = func(response):
		responses.append(response)
		if responses.size() == ids.size():
			responses_signal.emit()
	
	for id in ids:
		var url = BackgroundsBaseUrl.path_join(id + ".jpg")
		_request(url).connect(on_response)
	
	await responses_signal.emitted
	
	var task = func(index: int):
		_load_background_from_response(ids[index], responses[index])
	
	await AsyncWorkerThreadPool.add_group_task(task, responses.size())

func _save_background_to_cache(id: String, background: Image) -> void:
	var file_name = _id_to_file_name(id)
	var path = BackgroundsCacheFolderPath.path_join(file_name)
	background.save_jpg(path)

func _load_background_from_cache(id: String) -> void:
	
	var file_name = _id_to_file_name(id)
	var path = BackgroundsCacheFolderPath.path_join(file_name)
	var image = Image.load_from_file(path)
	
	if image == null:
		_backgrounds[id] = _fallback
		_print_error("_load_background_from_cache", "Error loading background from cache for id '%s'" % id)
	else:
		_backgrounds[id] = ImageTexture.create_from_image(image)

func _load_background_from_response(id: String, response: Dictionary) -> void:
	
	if response.error != null:
		_backgrounds[id] = _fallback
		_print_error("_load_background_from_response", "Error downloading background for id '%s': %s" % [id, response.error])
	
	var image = Image.new()
	var buffer_error = image.load_jpg_from_buffer(response.body)
	
	if buffer_error != OK:
		_backgrounds[id] = _fallback
		_print_error("_load_background_from_response", "Error loading buffer for id '%s': %s" % [id, error_string(buffer_error)])
	else:
		_backgrounds[id] = ImageTexture.create_from_image(image)
		_save_background_to_cache(id, image)


func _request(url: String) -> Signal:
	
	var result_signal = AsyncWorkerThreadPool.SignalEmitter.new()
	var http_request = HTTPRequest.new()
	var response = {
		"error": null,
		"result": null,
		"code": null,
		"headers": null,
		"body": null,
	}
	
	var make_request = func():
		var error = http_request.request(url)
		if error != OK:
			response.error = "Error fetching '%s': %s" % [url, error_string(error)]
			http_request.queue_free()
			result_signal.emit(response)
	
	var on_request_completed = func(result, response_code, headers, body) -> void:
		response.result = result
		response.code = response_code
		response.headers = headers
		response.body = body
		http_request.queue_free()
		result_signal.emit(response)
	
	http_request.ready.connect(make_request)
	http_request.request_completed.connect(on_request_completed)
	
	add_child.call_deferred(http_request)
	
	return result_signal.emitted

func _is_cached(id: String) -> bool:
	var file_name = _id_to_file_name(id)
	var path = BackgroundsCacheFolderPath.path_join(file_name)
	return FileAccess.file_exists(path)

func _id_to_file_name(id: String) -> String:
	return id.uri_encode() + ".jpg"


func _print(method: String, message) -> void:
	print(name, '::', method, ' - ', message)

func _print_error(method: String, message) -> void:
	printerr(name, '::', method, ' - ', message)
