extends Control

@onready var nickname_edit = $Panel/VBoxContainer/NicknameEdit
@onready var password_edit = $Panel/VBoxContainer/PasswordEdit
@onready var email_edit = $Panel/VBoxContainer/EmailEdit
@onready var register_button = $Panel/VBoxContainer/RegisterButton
@onready var cancel_button = $Panel/VBoxContainer/CancelButton
@onready var error_label = $Panel/VBoxContainer/ErrorLabel


func _ready():
	register_button.pressed.connect(_on_register_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	Session.login_failure.connect(_on_register_failure) # Re-using login_failure for simplicity


func _on_register_pressed():
	var nickname = nickname_edit.text
	var password = password_edit.text
	var email = email_edit.text
	Session.register(nickname, password, email)


func _on_cancel_pressed():
	Main.set_scene(Main.TITLE)


func _on_register_failure(error_message):
	error_label.text = error_message
