extends Node2D
class_name Editor

@onready var back = $UI/Back
@onready var test = $UI/Test
@onready var level_encoder = $LevelEncoder
@onready var level_decoder = $LevelDecoder
@onready var slider_menu = $UI/SliderMenu

static var current_level: Dictionary
var current_layer_name: String = "L1"


func _ready():
	back.connect("pressed", _on_back_pressed)
	test.connect("pressed", _on_test_pressed)
	slider_menu.connect("layer_changed", _on_layer_changed)
	if Editor.current_level:
		level_decoder.decode(Editor.current_level)
	else:
		level_decoder.decode({
			"layers": [{
				"name": "L1",
				"chunks": []
			}]
		})


func _on_back_pressed():
	Editor.current_level = level_encoder.encode()
	Helpers.set_scene("TITLE")


func _on_test_pressed():
	Editor.current_level = level_encoder.encode()
	var tester = Helpers.set_scene("TESTER")
	tester.set_level(Editor.current_level)


func _on_layer_changed(new_layer_name: String) -> void:
	current_layer_name = new_layer_name
