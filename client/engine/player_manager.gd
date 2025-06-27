extends Node
class_name PlayerManager

const CHARACTER = preload("res://character/character.tscn")

func spawn_player(layers: Layers, tiles: Tiles) -> CharacterBody2D:
	var start_option = Start.get_next_start_option(layers)
	if !start_option:
		return null
	var character = CHARACTER.instantiate()
	
	Session.set_current_player_layer(start_option.layer_name)
	
	var layer = layers.get_node(start_option.layer_name)
	if !layer:
		return null
	var player_holder = layer.get_node("Players")
	character.position = Vector2((start_option.coords * Settings.tile_size) + Settings.tile_size_half).rotated(start_option.tilemap.global_rotation if start_option.tilemap else 0)
	character.active = true
	player_holder.add_child(character)
	character.init(tiles)
	character.set_depth(layer.depth)
	
	Global.tile_map = layer.get_node("TileMap")
	Global.item_holder = character.get_node("Display/ItemHolder")
	
	return character
