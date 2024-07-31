extends Node2D
class_name Editor

var tiles: Tiles = Tiles.new()
var save_dir: String = "user://editor"
var save_file_path: String = save_dir + "/current-level.json"
var default_level: Dictionary = {
	"layers": [{
		"name": "L1",
		"chunks": [],
		"rotation": 0,
		"depth": 10
	}]
}
@onready var back = $UI/Back
@onready var test = $UI/Test
@onready var clear = $UI/Clear
@onready var level_encoder = $LevelEncoder
@onready var level_decoder = $LevelDecoder
@onready var editor_menu = $UI/EditorMenu
@onready var layers = $Layers

static var current_level: Dictionary


func _ready():
	Jukebox.play_url("https://tunes.platformracing.com/noodletown-4-remake-by-damon-bass.mp3")
	back.connect("pressed", _on_back_pressed)
	test.connect("pressed", _on_test_pressed)
	clear.connect("pressed", _on_clear_pressed)
	if Editor.current_level:
		level_decoder.decode(Editor.current_level)
	else:
		var saved_level = _load_from_file()
		if saved_level:
			level_decoder.decode(saved_level)
		else:
			level_decoder.decode(default_level)
	
	tiles.init_defaults()
	layers.init(tiles)


func _on_back_pressed():
	Editor.current_level = level_encoder.encode()
	_save_to_file(Editor.current_level)
	Helpers.set_scene("TITLE")


func _on_test_pressed():
	Editor.current_level = level_encoder.encode()
	_save_to_file(Editor.current_level)
	var tester = Helpers.set_scene("TESTER")
	tester.init(Editor.current_level)


func _on_clear_pressed():
	layers.clear()
	tiles.clear()
	Editor.current_level = default_level
	await get_tree().create_timer(0.1).timeout
	level_decoder.decode(default_level)
	layers.init(tiles)


func _save_to_file(level: Dictionary):
	# ensure directory exists
	if (!DirAccess.dir_exists_absolute(save_dir)):
		DirAccess.make_dir_absolute(save_dir)
	
	# save level to disk
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(level))
	file.close()


func _load_from_file():
	if not FileAccess.file_exists(save_file_path):
		return

	var file = FileAccess.open(save_file_path, FileAccess.READ)
	var level = JSON.parse_string(file.get_as_text())
	file.close()
	
	return level

