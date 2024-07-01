extends Node2D

const CHARACTER = preload("res://character/Character.tscn")

@onready var layers = $Layers
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
	var start_option = Start.get_next_start_option()
	var character = CHARACTER.instantiate()
	var layer = layers.get_node(start_option.layer_name)
	var player_holder = layer.get_node("Players")
	print("start_option ", start_option)
	character.position = (start_option.coords * Settings.tile_size) + Settings.tile_size_half
	character.active = true
	player_holder.add_child(character)


func _exit_tree():
	tiles.clear()
