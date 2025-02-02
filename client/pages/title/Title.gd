extends Control

@onready var guest_menu = $GuestMenu
@onready var online_button = $GuestMenu/OnlineButton
@onready var solo_button = $GuestMenu/SoloButton
@onready var credits_button = $GuestMenu/CreditsButton
@onready var editor_button = $GuestMenu/EditorButton
@onready var timer = $Timer
@onready var nickname_label: Label = $NicknameLabel


func _ready():
	Jukebox.play("noodletown-4-remake")
	#$Voter.init('2024/07/28', ['Just make all of the PR2 blocks work', 'Add a couple of new blocks', 'Save and share levels'])
	#$EditorButton.pressed.connect(_on_editor_pressed)
	
	online_button.pressed.connect(_online_pressed)
	solo_button.pressed.connect(_solo_pressed)
	credits_button.pressed.connect(_credits_pressed)
	editor_button.pressed.connect(_editor_pressed)
	
	timer.timeout.connect(_check_session)
	
	_check_session()


func _check_session():
	nickname_label.text = Session.nickname


func _solo_pressed():
	Helpers.set_scene("SOLO")


func _online_pressed():
	Helpers.set_scene("LOBBY")
	#if Session.is_logged_in():
		#Helpers.set_scene("LOBBY")
	#else:
		#if OS.has_feature('web'):
			#JavaScriptBridge.eval('window.location.replace("' + Helpers.get_base_url() + '/auth-ui/registration")')


func _logout_pressed():
	Session.end()


func _credits_pressed():
	Helpers.set_scene("CREDITS")


func _editor_pressed():
	Game.pr2_level_id = '0'
	Helpers.set_scene("LEVEL_EDITOR")
