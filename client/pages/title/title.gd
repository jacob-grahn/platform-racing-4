extends Control

@onready var awaiting_login_panel = $AwaitingLoginPanel
@onready var not_logged_in_panel = $NotLoggedInPanel
@onready var logged_in_panel = $LoggedInPanel
@onready var nlip_login_button = $NotLoggedInPanel/VBoxContainer/LoginButton
@onready var nlip_guest_play_button = $NotLoggedInPanel/VBoxContainer/GuestPlayButton
@onready var nlip_create_account_button = $NotLoggedInPanel/VBoxContainer/CreateAccountButton
@onready var nlip_level_editor_button = $NotLoggedInPanel/VBoxContainer/LevelEditorButton
@onready var nlip_credits_button = $NotLoggedInPanel/VBoxContainer/CreditsButton
@onready var lip_nickname_label = $LoggedInPanel/VBoxContainer/NicknameLabel
@onready var lip_lobby_button = $LoggedInPanel/VBoxContainer/LobbyButton
@onready var lip_level_editor_button = $LoggedInPanel/VBoxContainer/LevelEditorButton
@onready var lip_credits_button = $LoggedInPanel/VBoxContainer/CreditsButton
@onready var lip_user_settings_button = $LoggedInPanel/VBoxContainer/UserSettingsButton
@onready var lip_logout_button = $LoggedInPanel/VBoxContainer/LogoutButton


func _ready():
	logged_in_panel.hide()
	not_logged_in_panel.hide()
	awaiting_login_panel.show()
	Jukebox.play("noodletown-4-remake")
	
	nlip_login_button.pressed.connect(_on_login_pressed)
	nlip_create_account_button.pressed.connect(_on_create_account_pressed)
	nlip_level_editor_button.pressed.connect(_on_level_editor_pressed)
	nlip_credits_button.pressed.connect(_on_credits_pressed)
	lip_lobby_button.pressed.connect(_on_login_pressed)
	lip_level_editor_button.pressed.connect(_on_level_editor_pressed)
	lip_credits_button.pressed.connect(_on_credits_pressed)
	lip_logout_button.pressed.connect(_on_logout_pressed)
	lip_user_settings_button.pressed.connect(_on_user_settings_pressed)
	
	Session.login_success.connect(_update_ui)
	Session.logout_success.connect(_update_ui)
	
	_update_ui()


func _update_ui():
	if awaiting_login_panel.visible:
		awaiting_login_panel.hide()
	if Session.is_logged_in():
		lip_nickname_label.text = "Welcome, " + Session.nickname + "!"
		not_logged_in_panel.hide()
		logged_in_panel.show()
	else:
		logged_in_panel.hide()
		not_logged_in_panel.show()


func _on_login_pressed():
	if Session.is_logged_in():
		Main.set_scene(Main.LOBBY)
	else:
		Main.set_scene(Main.LOGIN)

func _on_create_account_pressed():
	Main.set_scene(Main.REGISTER)

func _on_level_editor_pressed():
	Main.set_scene(Main.LEVEL_EDITOR)

func _on_credits_pressed():
	Main.set_scene(Main.CREDITS)

func _on_logout_pressed():
	logged_in_panel.hide()
	not_logged_in_panel.hide()
	awaiting_login_panel.show()
	Session.logout()


func _on_user_settings_pressed():
	Main.set_scene(Main.USER_SETTINGS)
