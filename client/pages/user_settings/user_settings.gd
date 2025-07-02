extends Control

@onready var new_nickname_edit = $VBoxContainer/NewNicknameEdit
@onready var nickname_password_edit = $VBoxContainer/NicknamePasswordEdit
@onready var update_nickname_button = $VBoxContainer/UpdateNicknameButton
@onready var current_password_edit = $VBoxContainer/CurrentPasswordEdit
@onready var new_password_edit = $VBoxContainer/NewPasswordEdit
@onready var update_password_button = $VBoxContainer/UpdatePasswordButton
@onready var back_button = $VBoxContainer/BackButton
@onready var status_label = $VBoxContainer/StatusLabel
@onready var update_nickname_request = $UpdateNicknameRequest
@onready var update_password_request = $UpdatePasswordRequest


func _ready():
	update_nickname_button.pressed.connect(_on_update_nickname_pressed)
	update_password_button.pressed.connect(_on_update_password_pressed)
	back_button.pressed.connect(_on_back_pressed)
	update_nickname_request.request_completed.connect(_on_update_nickname_request_completed)
	update_password_request.request_completed.connect(_on_update_password_request_completed)


func _on_update_nickname_pressed():
	var new_nickname = new_nickname_edit.text
	if new_nickname.is_empty():
		status_label.text = "New nickname cannot be empty."
		return

	var body = {
		"nickname": Session.nickname,
		"new_nickname": new_nickname,
		"password": nickname_password_edit.text
	}
	_make_request(update_nickname_request, body)


func _on_update_password_pressed():
	var current_password = current_password_edit.text
	var new_password = new_password_edit.text

	if current_password.is_empty() or new_password.is_empty():
		status_label.text = "Passwords cannot be empty."
		return

	var body = {
		"nickname": Session.nickname,
		"password": current_password,
		"new_password": new_password
	}
	_make_request(update_password_request, body)


func _make_request(request_node, body):
	var headers = ["Content-Type: application/json"]
	var body_json = JSON.stringify(body)
	var error = request_node.request(ApiManager.get_base_url() + "/auth/update", headers, HTTPClient.METHOD_POST, body_json)
	if error != OK:
		status_label.text = "An error occurred: " + str(error)


func _on_update_nickname_request_completed(result, response_code, headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())
	if response_code == 200:
		status_label.text = response.get("message", "Success!")
		Session.set_nickname(new_nickname_edit.text)
	else:
		status_label.text = response.get("error", "An unknown error occurred.")


func _on_update_password_request_completed(result, response_code, headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())
	if response_code == 200:
		status_label.text = response.get("message", "Success!")
	else:
		status_label.text = response.get("error", "An unknown error occurred.")


func _on_back_pressed():
	Main.set_scene(Main.TITLE)
