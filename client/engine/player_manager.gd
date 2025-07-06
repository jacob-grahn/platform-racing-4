extends Node
class_name PlayerManager

const CHARACTER = preload("res://character/character.tscn")

var character: CharacterBody2D


func get_character() -> CharacterBody2D:
	return character


func spawn_player(layers: Layers, tiles: Tiles) -> CharacterBody2D:
	var start_option = Start.get_next_start_option(layers)
	if !start_option:
		return null
	character = CHARACTER.instantiate()
	
	if Game.game:
		Game.game.set_current_player_layer(start_option.layer_name)
	
	var layer = layers.get_node(start_option.layer_name)
	if !layer:
		return null
	var player_holder = layer.get_node("Players")
	character.position = Vector2((start_option.coords * Settings.tile_size) + Settings.tile_size_half).rotated(start_option.tilemap.global_rotation if start_option.tilemap else 0)
	character.active = true
	player_holder.add_child(character)
	character.init(tiles)
	character.set_depth(layer.depth)
	
	return character
