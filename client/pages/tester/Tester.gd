extends Node2D

const CHARACTER = preload("res://character/Character.tscn")

@onready var layers = $Layers
@onready var level_decoder = $LevelDecoder
@onready var back = $UI/Back
@onready var minimap_container = $UI/Minimaps

var tiles: Tiles = Tiles.new()


func _ready():
	tiles.init_defaults()
	back.connect("pressed", _on_back_pressed)
	Jukebox.play("pr1-future-penumbra")


func _on_back_pressed():
	Helpers.set_scene("EDITOR")


func init(level: Dictionary):
	level_decoder.decode(level, false)
	layers.init(tiles)
	tiles.activate_node($Layers)
	var start_option = Start.get_next_start_option(layers)
	var character = CHARACTER.instantiate()
	
	Session.set_current_player_layer(start_option.layer_name)
	for child in minimap_container.get_children():
		child.visible = child.name == start_option.layer_name
	
	var layer = layers.get_node(start_option.layer_name)
	var player_holder = layer.get_node("Players")
	character.position = Vector2((start_option.coords * Settings.tile_size) + Settings.tile_size_half).rotated(start_option.tilemap.global_rotation if start_option.tilemap else 0)
	character.active = true
	player_holder.add_child(character)
	character.set_depth(layer.depth)

func finish():
	Helpers.set_scene("EDITOR")


func _exit_tree():
	tiles.clear()
