extends Control

@onready var back_button: Button = $BackButton
@onready var solo_button: Button = $SoloButton
@onready var level_editor_button: Button = $LevelEditorButton
@onready var credits_button: Button = $CreditsButton
@onready var character_editor_button: Button = $CharacterEditorButton


func _ready() -> void:
	back_button.connect("pressed", _on_back_pressed)
	solo_button.pressed.connect(_solo_pressed)
	credits_button.pressed.connect(_credits_pressed)
	level_editor_button.pressed.connect(_level_editor_pressed)
	character_editor_button.pressed.connect(_character_editor_pressed)


func _on_back_pressed():
	Main.set_scene(Main.TITLE)


func _credits_pressed():
	Main.set_scene(Main.CREDITS)


func _solo_pressed():
	Main.set_scene(Main.SOLO)


func _level_editor_pressed():
	Game.pr2_level_id = '0'
	Main.set_scene(Main.LEVEL_EDITOR)


func _character_editor_pressed():
	Main.set_scene(Main.CHARACTER_EDITOR)
