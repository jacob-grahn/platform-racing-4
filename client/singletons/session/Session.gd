extends Node2D

@onready var http = $HTTP
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
	http.request("https://dev.platformracing.com/auth/sessions/whoami")


func start_guest_session():
	player_id = ""
	nickname = "guest " + str(randi_range(0, 999))
	is_guest = true


func end():
	player_id = ""
	is_guest = true
	nickname = ""
