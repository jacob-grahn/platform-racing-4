extends Control

@onready var join_button = $JoinButton
@onready var close_button: Button = $CloseButton
@onready var title_edit: TextEdit = $TitleEdit
@onready var game_client: Node2D = $"../../GameClient"

func _ready():
	self.visible = false

func initialize() -> void:
	self.visible = true

	join_button.connect("pressed", _join_pressed)
	close_button.connect("pressed", _close_pressed)

func close() -> void:
	self.visible = false

func _close_pressed():
	close()

func _join_pressed():
	if title_edit.text == "":
		return
	
	game_client.join(title_edit.text, false)
	close()
