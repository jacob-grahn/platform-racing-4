extends Control

@onready var text_edit: TextEdit = $TextEdit
@onready var back_button: Button = $BackButton
@onready var solo_button: Button = $SoloButton
@onready var editor_button: Button = $EditorButton
@onready var credits_button: Button = $CreditsButton


func _ready() -> void:
	back_button.connect("pressed", _on_back_pressed)
	solo_button.pressed.connect(_solo_pressed)
	credits_button.pressed.connect(_credits_pressed)
	editor_button.pressed.connect(_editor_pressed)


func _on_back_pressed():
	Helpers.set_scene("TITLE")


func _credits_pressed():
	Helpers.set_scene("CREDITS")


func _solo_pressed():
	Helpers.set_scene("SOLO")


func _editor_pressed():
	Game.pr2_level_id = '0'
	Helpers.set_scene("LEVEL_EDITOR")
