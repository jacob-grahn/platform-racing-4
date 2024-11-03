extends Node2D

@onready var http = $HTTP
@onready var http_logout = $HTTPLogout
var player_id = ""
var nickname = ""
var is_guest = true
var _used_rect: Rect2i = Rect2i(0, 0, 0, 0)
var _player_position: Vector2 = Vector2.ZERO

func _ready():
	http.request_completed.connect(_request_completed)
	refresh()
	
func set_used_rect(value: Rect2i) -> void:
	_used_rect = value

func get_used_rect() -> Rect2i:
	return _used_rect

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
	http.request(Helpers.get_base_url() + "/auth/sessions/whoami")


func start_guest_session():
	player_id = ""
	nickname = "guest " + str(randi_range(0, 999))
	is_guest = true


func end():
	player_id = ""
	is_guest = true
	nickname = ""
	if OS.has_feature('web'):
		http_logout.request(Helpers.get_base_url() + '/auth/self-service/logout/browser')
	
	
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
