extends Control

@onready var text_edit: TextEdit = $TextEdit
@onready var back_button: Button = $BackButton


func _ready() -> void:
	back_button.connect("pressed", _on_back_pressed)


func _on_back_pressed():
	Helpers.set_scene("TITLE")
