extends Node2D
class_name Editor

var tiles: Tiles = Tiles.new()
var default_level: Dictionary = {
	"layers": [{
		"name": "Layer 1",
		"chunks": [],
		"rotation": 0,
		"depth": 10
	}]
}
@onready var back = $UI/Back
@onready var test = $UI/Test
@onready var load = $UI/Load
@onready var save = $UI/Save
@onready var clear = $UI/Clear
@onready var level_encoder = $LevelEncoder
@onready var level_decoder = $LevelDecoder
@onready var editor_menu = $UI/EditorMenu
@onready var layers = $Layers
@onready var layer_panel = $UI/LayerPanel
@onready var save_panel = $UI/SavePanel
@onready var load_panel = $UI/LoadPanel

static var current_level: Dictionary

func _ready():
	Jukebox.play("noodletown-4-remake")
	back.connect("pressed", _on_back_pressed)
	load.connect("pressed", _on_load_pressed)
	save.connect("pressed", _on_save_pressed)
	test.connect("pressed", _on_test_pressed)
	clear.connect("pressed", _on_clear_pressed)
	load_panel.connect("level_load", _on_load_level)
	
	if Editor.current_level:
		level_decoder.decode(Editor.current_level, true)
	else:
		var saved_level = Helpers._load_from_file()
		if saved_level:
			level_decoder.decode(saved_level, true)
		else:
			level_decoder.decode(default_level, true)
	
	tiles.init_defaults()
	layers.init(tiles)
	layer_panel.set_layers(layers)


func _on_back_pressed():
	Editor.current_level = level_encoder.encode()
	Helpers._save_to_file(Editor.current_level)
	Helpers.set_scene("TITLE")

func _on_load_pressed():
	save_panel.close()
	load_panel.initialize()
	
func _on_save_pressed():
	Editor.current_level = level_encoder.encode()
	load_panel.close()
	save_panel.initialize(Editor.current_level)

func _on_test_pressed():
	Editor.current_level = level_encoder.encode()
	Helpers._save_to_file(Editor.current_level)
	var tester = Helpers.set_scene("TESTER")
	tester.init(Editor.current_level)

func _on_clear_pressed():
	_on_load_level("")

func _on_load_level(level_name = ""):
	Helpers._set_current_level_name(level_name)
	
	var selected_level = default_level
	if (level_name != ""):
		selected_level = Helpers._load_from_file(level_name)
		
	layers.clear()
	tiles.clear()
	Editor.current_level = selected_level
	await get_tree().create_timer(0.1).timeout
	level_decoder.decode(selected_level, true)
	layers.init(tiles)
