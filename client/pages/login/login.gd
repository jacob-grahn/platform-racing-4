extends Control

@onready var nickname_edit = $Panel/VBoxContainer/NicknameEdit
@onready var password_edit = $Panel/VBoxContainer/PasswordEdit
@onready var login_button = $Panel/VBoxContainer/LoginButton
@onready var cancel_button = $Panel/VBoxContainer/CancelButton
@onready var error_label = $Panel/VBoxContainer/ErrorLabel


func _ready():
	login_button.pressed.connect(_on_login_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	Session.login_success.connect(_on_login_success)
	Session.login_failure.connect(_on_login_failure)


func _on_login_pressed():
	var nickname = nickname_edit.text
	var password = password_edit.text
	Session.login(nickname, password)


func _on_cancel_pressed():
	Main.set_scene(Main.TITLE)


func _on_login_success():
	Main.set_scene(Main.LOBBY)


func _on_login_failure(error_message):
	error_label.text = error_message
