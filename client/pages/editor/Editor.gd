extends Node2D
class_name Editor

static var current_level: Dictionary

@onready var back = $UI/Back
@onready var test = $UI/Test
@onready var level_encoder = $LevelEncoder
@onready var level_decoder = $LevelDecoder


func _ready():
	back.connect("pressed", _on_back_pressed)
	test.connect("pressed", _on_test_pressed)
	if Editor.current_level:
		level_decoder.decode(Editor.current_level)


func _on_back_pressed():
	Editor.current_level = level_encoder.encode()
	Helpers.set_scene(Main.TITLE)


func _on_test_pressed():
	Editor.current_level = level_encoder.encode()
	Helpers.set_scene(Main.TESTER)
