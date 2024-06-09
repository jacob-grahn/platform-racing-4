extends Node2D

@onready var level_decoder = $LevelDecoder
@onready var back = $UI/Back
var tiles: Tiles = Tiles.new()


func _ready():
	tiles.init_defaults()
	back.connect("pressed", _on_back_pressed)


func _on_back_pressed():
	Helpers.set_scene("EDITOR")


func set_level(level: Dictionary) -> void:
	level_decoder.decode(level)
	activate()


func activate():
	tiles.activate_node($Layers)
	$Character.position = Start.get_next_start_coords() * Settings.tile_size + Settings.tile_size_half
	$Character.active = true
