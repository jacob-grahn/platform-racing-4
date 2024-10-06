extends Node2D

@onready var http = $HTTP
@onready var http_logout = $HTTPLogout
var player_id = ""
var nickname = ""
var is_guest = true


func _ready():
	http.request_completed.connect(_request_completed)
	refresh()


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
