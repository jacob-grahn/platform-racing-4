extends Node2D
class_name Editor

var tiles: Tiles = Tiles.new()
@onready var back = $UI/Back
@onready var test = $UI/Test
@onready var level_encoder = $LevelEncoder
@onready var level_decoder = $LevelDecoder
@onready var editor_menu = $UI/EditorMenu
@onready var layers = $Layers

static var current_level: Dictionary


func _ready():
	Jukebox.play_url("https://tunes.platformracing.com/noodletown-4-remake-by-damon-bass.mp3")
	back.connect("pressed", _on_back_pressed)
	test.connect("pressed", _on_test_pressed)
	if Editor.current_level:
		level_decoder.decode(Editor.current_level)
	else:
		level_decoder.decode({
			"layers": [{
				"name": "L1",
				"chunks": [],
				"rotation": 0,
				"depth": 10
			}]
		})
	
	tiles.init_defaults()
	layers.init(tiles)


func _on_back_pressed():
	Editor.current_level = level_encoder.encode()
	Helpers.set_scene("TITLE")


func _on_test_pressed():
	Editor.current_level = level_encoder.encode()
	var tester = Helpers.set_scene("TESTER")
	tester.init(Editor.current_level)
