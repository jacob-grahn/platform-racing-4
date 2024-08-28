extends Node2D

@onready var guest_menu = $GuestMenu
@onready var log_in_button = $GuestMenu/LogInButton
@onready var guest_button = $GuestMenu/GuestButton
@onready var create_button = $GuestMenu/CreateButton
@onready var credits_button = $GuestMenu/CreditsButton
@onready var player_menu = $PlayerMenu
@onready var nickname_label = $PlayerMenu/NicknameLabel
@onready var play_button = $PlayerMenu/PlayButton
@onready var editor_button = $PlayerMenu/EditorButton
@onready var logout_button = $PlayerMenu/LogoutButton
@onready var timer = $Timer
@onready var text_edit = $PlayerMenu/TextEdit


func _ready():
	Jukebox.play_url("https://tunes.platformracing.com/noodletown-4-remake-by-damon-bass.mp3")
	#$Voter.init('2024/07/28', ['Just make all of the PR2 blocks work', 'Add a couple of new blocks', 'Save and share levels'])
	#$EditorButton.pressed.connect(_on_editor_pressed)
	
	log_in_button.pressed.connect(_log_in_pressed)
	guest_button.pressed.connect(_guest_pressed)
	create_button.pressed.connect(_create_pressed)
	credits_button.pressed.connect(_credits_pressed)
	
	play_button.pressed.connect(_play_pressed)
	editor_button.pressed.connect(_editor_pressed)
	logout_button.pressed.connect(_logout_pressed)
	
	timer.timeout.connect(_check_session)
	
	_check_session()


func _check_session():
	var is_in = false
	if Session.nickname:
		is_in = true
		
	guest_menu.visible = !is_in
	player_menu.visible = is_in
	nickname_label.text = Session.nickname


func _play_pressed():
	Game.pr2_level_id = text_edit.text
	Helpers.set_scene("GAME")


func _guest_pressed():
	Session.start_guest_session()


func _create_pressed():
	if OS.has_feature('JavaScript'):
		JavaScriptBridge.eval('window.location.replace("https://dev.platformracing.com/auth-ui/login")')


func _log_in_pressed():
	if OS.has_feature('JavaScript'):
		JavaScriptBridge.eval('window.location.replace("https://dev.platformracing.com/auth-ui/registration")')


func _logout_pressed():
	if OS.has_feature('JavaScript'):
		JavaScriptBridge.eval('window.location.replace("https://dev.platformracing.com/auth/self-service/logout?token=ory_lo")')
	else:
		Session.end()


func _credits_pressed():
	Helpers.set_scene("CREDITS")


func _editor_pressed():
	Game.pr2_level_id = '0'
	Helpers.set_scene("EDITOR")
