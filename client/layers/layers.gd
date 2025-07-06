extends Node2D
class_name Layers

const LAYER = preload("res://layers/layer.tscn")
var target_layer: String = ""
var tile_config: Tiles


func init(p_tile_config: Tiles) -> void:
	tile_config = p_tile_config
	for layer in get_children():
		if layer is Layer:
			layer.init(tile_config)


func clear() -> void:
	for layer in get_children():
		layer.queue_free()


func set_target_layer(layer_name: String) -> void:
	target_layer = layer_name


func get_target_layer() -> String:
	if get_child_count() == 0:
		target_layer = ""
		return target_layer
	if target_layer == "" || !get_node(target_layer):
		target_layer = get_child(0).name
	return target_layer


func add_layer(name: String) -> Layer:
	var layer = LAYER.instantiate()
	layer.name = name
	layer.layer = 10
	add_child(layer)
	if tile_config:
		layer.init(tile_config)
	return layer


func remove_layer(name: String) -> void:
	var layer = get_node(name)
	if layer:
		remove_child(layer)
		layer.queue_free()


func calc_used_rect() -> void:
	for layer in get_children():
		var tilemap = layer.get_node("TileMap")
		var map_used_rect = tilemap.get_used_rect()
		if Game.game:
			Game.game.set_used_rect(layer.name, map_used_rect)
