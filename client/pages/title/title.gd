extends Control

@onready var play_button = $PlayButton
@onready var nickname_label = $HBoxContainer/NicknameLabel
@onready var logout_button = $HBoxContainer/LogoutButton


func _ready():
	Jukebox.play("noodletown-4-remake")
	
	play_button.pressed.connect(_on_play_pressed)
	logout_button.pressed.connect(_on_logout_pressed)
	
	Session.login_success.connect(_update_ui)
	Session.logout_success.connect(_update_ui)
	
	_update_ui()


func _update_ui():
	if Session.is_logged_in():
		nickname_label.text = Session.nickname
		nickname_label.show()
		logout_button.show()
	else:
		nickname_label.hide()
		logout_button.hide()


func _on_play_pressed():
	if Session.is_logged_in():
		Main.set_scene(Main.LOBBY)
	else:
		Main.set_scene(Main.LOGIN)


func _on_logout_pressed():
	Session.logout()
