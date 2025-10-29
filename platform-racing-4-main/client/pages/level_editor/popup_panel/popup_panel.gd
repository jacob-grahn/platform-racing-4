extends Control

@onready var close_button = $CloseButton
@onready var title_label: Label = $TitleLabel
@onready var body_label: Label = $BodyLabel

func _ready():
	self.visible = false

func initialize(title: String, body: String) -> void:
	self.visible = true

	title_label.text = title
	body_label.text = body
	
	close_button.connect("pressed", _close_pressed)

func close() -> void:
	self.visible = false

func _close_pressed():
	close()
