extends Node

signal login_success
signal login_failure(error_message)
signal logout_success
signal session_updated

const TOKEN_FILE = "user://session.dat"

var access_token: String = ""
var refresh_token: String = ""
var nickname: String = ""
var _last_login_nickname: String = ""

var http_login: HTTPRequest
var http_register: HTTPRequest
var http_refresh: HTTPRequest

func _ready():
	http_login = HTTPRequest.new()
	http_register = HTTPRequest.new()
	http_refresh = HTTPRequest.new()
	add_child(http_login)
	add_child(http_register)
	add_child(http_refresh)

	http_login.request_completed.connect(_on_login_request_completed)
	http_register.request_completed.connect(_on_register_request_completed)
	http_refresh.request_completed.connect(_on_refresh_request_completed)

	load_tokens()
	if refresh_token:
		refresh_access_token()

func login(p_nickname: String, p_password: String):
	_last_login_nickname = p_nickname
	var body = {
		"nickname": p_nickname,
		"password": p_password
	}
	var headers = ["Content-Type: application/json"]
	http_login.request(ApiManager.get_base_url() + "/auth/login", headers, HTTPClient.METHOD_POST, JSON.stringify(body))

func register(p_nickname: String, p_password: String, p_email: String = ""):
	var body = {
		"nickname": p_nickname,
		"password": p_password,
		"email": p_email
	}
	var headers = ["Content-Type: application/json"]
	http_register.request(ApiManager.get_base_url() + "/auth/register", headers, HTTPClient.METHOD_POST, JSON.stringify(body))

func refresh_access_token():
	if !refresh_token:
		return

	var headers = ["Content-Type: application/json", "Authorization: " + refresh_token]
	http_refresh.request(ApiManager.get_base_url() + "/auth/refresh", headers, HTTPClient.METHOD_POST, "")

func logout():
	access_token = ""
	refresh_token = ""
	nickname = ""
	save_tokens()
	emit_signal("logout_success")

func is_logged_in() -> bool:
	return access_token != ""

func set_nickname(new_nickname: String):
	nickname = new_nickname
	emit_signal("session_updated")

func _on_login_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json:
			access_token = json.get("access_token", "")
			refresh_token = json.get("refresh_token", "")
			nickname = _last_login_nickname
			save_tokens()
			emit_signal("login_success")
		else:
			emit_signal("login_failure", "Invalid response from server.")
	else:
		var error_message = "Login failed."
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and json.has("error"):
			error_message = json["error"]
		emit_signal("login_failure", error_message)

func _on_register_request_completed(result, response_code, headers, body):
	if response_code == 201:
		# Automatically log in after successful registration
		var json = JSON.parse_string(body.get_string_from_utf8())
		# Assuming the registration request had nickname and password
		# This is a bit of a simplification. A better approach might be to have the register endpoint return tokens.
		# For now, we'll just tell the user to log in.
		emit_signal("login_failure", "Registration successful! Please log in.")
	else:
		var error_message = "Registration failed."
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and json.has("error"):
			error_message = json["error"]
		emit_signal("login_failure", error_message)


func _on_refresh_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json:
			access_token = json.get("access_token", "")
			save_tokens()
			emit_signal("login_success")
		else:
			logout() # Invalid response, so log out
	else:
		# If refresh fails, clear tokens
		logout()

func save_tokens():
	var file = FileAccess.open(TOKEN_FILE, FileAccess.WRITE)
	if file:
		var data = {
			"refresh_token": refresh_token,
			"nickname": nickname
		}
		file.store_string(JSON.stringify(data))

func load_tokens():
	if FileAccess.file_exists(TOKEN_FILE):
		var file = FileAccess.open(TOKEN_FILE, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var data = JSON.parse_string(content)
			if data:
				refresh_token = data.get("refresh_token", "")
				nickname = data.get("nickname", "")
