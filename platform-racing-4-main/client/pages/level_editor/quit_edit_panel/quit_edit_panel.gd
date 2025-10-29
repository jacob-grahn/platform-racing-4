extends Control

@onready var confirm_button = $ConfirmButton
@onready var close_button: Button = $CloseButton
@onready var title_edit: TextEdit = $TitleEdit
@onready var game_client: Node2D = get_node("/root/Main/GameClient")

func _ready():
	self.visible = false

func initialize(room: String) -> void:
	title_edit.text = room
	self.visible = true

	confirm_button.connect("pressed", _confirm_pressed)
	close_button.connect("pressed", _close_pressed)

func close() -> void:
	self.visible = false

func _close_pressed():
	close()

func _confirm_pressed():
	if title_edit.text == "":
		return
	
	game_client.quit(title_edit.text)
	close()
