extends Control

@onready var close_button = $CloseButton
@onready var title_edit: TextEdit = $TitleEdit
@onready var game_client: Node2D = get_node("/root/Main/GameClient")

func _ready():
	title_edit.text = StringUtils.generate_uuidv4()
	self.visible = false

func initialize(roomId: String) -> void:
	title_edit.text = roomId
	self.visible = true

	close_button.connect("pressed", _close_pressed)

func close() -> void:
	self.visible = false

func _close_pressed():
	close()
