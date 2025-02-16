extends Control

@onready var guest_menu = $GuestMenu
@onready var online_button = $GuestMenu/OnlineButton
@onready var timer = $Timer
@onready var nickname_label: Label = $NicknameLabel


func _ready():
	Jukebox.play("noodletown-4-remake")
	#$Voter.init('2024/07/28', ['Just make all of the PR2 blocks work', 'Add a couple of new blocks', 'Save and share levels'])
	#$EditorButton.pressed.connect(_on_editor_pressed)
	
	online_button.pressed.connect(_online_pressed)
	timer.timeout.connect(_check_session)
	
	_check_session()


func _check_session():
	nickname_label.text = Session.nickname


func _online_pressed():
	Main.set_scene(Main.LOBBY)
	#if Session.is_logged_in():
		#Main.set_scene(Main.LOBBY)
	#else:
		#if OS.has_feature('web'):
			#JavaScriptBridge.eval('window.location.replace("' + Helpers.get_base_url() + '/auth-ui/registration")')


func _logout_pressed():
	Session.end()
