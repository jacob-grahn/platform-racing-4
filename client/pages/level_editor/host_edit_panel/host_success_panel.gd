extends Control

@onready var close_button = $SmallPanel/VBoxContainer/CloseButton
@onready var room_code: RichTextLabel = $SmallPanel/VBoxContainer/RoomCodeText
@onready var game_client: Node2D = get_node("/root/Main/GameClient")

func _ready():
	room_code.text = StringUtils.generate_uuidv4()
	self.visible = false

func initialize(roomId: String) -> void:
	room_code.text = roomId
	self.visible = true

	close_button.connect("pressed", _close_pressed)

func close() -> void:
	self.visible = false

func _close_pressed():
	close()
