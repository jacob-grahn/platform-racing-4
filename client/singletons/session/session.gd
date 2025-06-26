extends Object

var http = HTTPRequest.new()
var http_logout = HTTPRequest.new()
var player_id = ""
var nickname = ""
var is_guest = true
var _current_scene_name: String = ""
var _current_player_layer: String = ""
var _username: String
var _used_rects: Dictionary = {}
var _player_position: Vector2 = Vector2.ZERO
var _current_block_id = 0

func _ready():
	var main_scene = Engine.get_main_loop().root
	main_scene.add_child.call_deferred(http)
	main_scene.add_child.call_deferred(http_logout)
	_username = Globals.Helpers.generate_username()
	http.request_completed.connect(_request_completed)
	http_logout.request_completed.connect(_logout_request_completed)
	await Engine.get_main_loop().process_frame
	refresh()


func set_current_block_id(value: int) -> void:
	_current_block_id = value


func get_current_block_id() -> int:
	return _current_block_id


func set_current_scene_name(value: String) -> void:
	_current_scene_name = value


func get_current_scene_name() -> String:
	return _current_scene_name


func set_current_player_layer(value: String) -> void:
	_current_player_layer = value


func get_current_player_layer() -> String:
	return _current_player_layer


func get_username() -> String:
	return _username
	

func set_username(value: String) -> void:
	_username = value


func set_used_rect(layer_name: String, value: Rect2i) -> void:
	_used_rects[layer_name] = value


func get_used_rect() -> Rect2i:
	if _used_rects.has(_current_player_layer):
		return _used_rects[_current_player_layer]
	else:
		return Rect2i(0, 0, 0, 0)


func set_player_position(value: Vector2) -> void:
	_player_position = value


func get_player_position() -> Vector2:
	return _player_position


func _request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Session couldn't be fetched. Result: " + str(result))
		return
		
	if response_code == 401:
		player_id = ""
		print("Session::_request_completed - no session")
		return
		
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	if error != OK:
		print("Session::_request_completed - json parse error: ", error)
		return
		
	var data = json.data
	player_id = data.identity.id
	nickname = data.identity.traits.nickname
	is_guest = false
	print("Session::_request_completed - loaded session: ", nickname)


func refresh():
	pass
	#http.request(Globals.Helpers.get_base_url() + "/auth/sessions/whoami")


func start_guest_session():
	player_id = ""
	nickname = "guest " + str(randi_range(0, 999))
	is_guest = true


func end():
	player_id = ""
	is_guest = true
	nickname = ""
	if OS.has_feature('web'):
		http_logout.request(Globals.Helpers.get_base_url() + '/auth/self-service/logout/browser')
	
	
func _logout_request_completed(result: int, response_code: int, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Session couldn't be deleted. Result: " + str(result))
		return
		
	if response_code != 200:
		print("Session::_logout_request_completed - response code: ", response_code)
		return
		
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	if error != OK:
		print("Session::_logout_request_completed - json parse error: ", error)
		return
		
	var data = json.data
	if (data.error):
		print(data.error)
		return
		
	JavaScriptBridge.eval("window.location = '" + data.logout_url + "';")


func is_logged_in() -> bool:
	return nickname != ""
