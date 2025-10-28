extends Node
class_name LevelManager

var tiles: Tiles = Tiles.new()

@onready var layers: Layers = $Layers
@onready var level_decoder: LevelDecoder = $LevelDecoder
@onready var level_encoder: LevelEncoder = $LevelEncoder


func _ready() -> void:
	tiles.init_defaults()
	layers.init(tiles)


func encode_level() -> Dictionary:
	var bg = get_parent().get_node("BG")
	return level_encoder.encode(layers, bg)


func decode_level(level_data: Dictionary, is_editor: bool) -> void:
	level_decoder.decode(level_data, is_editor, layers)


func clear() -> void:
	layers.clear()
	tiles.clear()


func activate_node() -> void:
	tiles.activate_node(layers)


func calc_used_rect() -> void:
	layers.calc_used_rect()
