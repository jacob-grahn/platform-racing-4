extends Control

@onready var host_button = $HostButton
@onready var close_button = $CloseButton
@onready var title_edit: TextEdit = $TitleEdit
@onready var game_client: Node2D = $"../../GameClient"

func _ready():
	title_edit.text = Helpers.generate_uuidv4()
	self.visible = false

func initialize() -> void:
	self.visible = true

	host_button.connect("pressed", _host_pressed)
	close_button.connect("pressed", _close_pressed)

func close() -> void:
	self.visible = false

func _host_pressed():
	if title_edit.text == "":
		return
	
	game_client.join(title_edit.text, true)
	close()
	
func _close_pressed():
	close()
	
	
