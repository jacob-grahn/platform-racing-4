extends Node2D
class_name Layers

const LAYER = preload("res://layers/layer.tscn")
const BLOCK_LAYER = preload("res://layers/blocklayer.tscn")
const ART_LAYER = preload("res://layers/artlayer.tscn")
@onready var block_layers = $BlockLayers
@onready var art_layers = $ArtLayers
var target_layer: String = ""
var block_target_layer: String = ""
var art_target_layer: String = ""
var tile_config: Tiles


func init(p_tile_config: Tiles) -> void:
	tile_config = p_tile_config
	for layer in block_layers.get_children():
		if layer is Layer or layer is BlockLayer:
			layer.init(tile_config)
	for layer in art_layers.get_children():
		if layer is Layer or layer is BlockLayer:
			layer.init(tile_config)


func clear() -> void:
	for layer in block_layers.get_children():
		layer.queue_free()
	for layer in art_layers.get_children():
		layer.queue_free()


func set_target_layer(layer_name: String) -> void:
	target_layer = layer_name


func set_target_block_layer(layer_name: String) -> void:
	block_target_layer = layer_name


func set_target_art_layer(layer_name: String) -> void:
	art_target_layer = layer_name


func get_target_layer() -> String:
	if get_child_count() == 0:
		target_layer = ""
		return target_layer
	if target_layer == "" || !get_node(target_layer):
		target_layer = get_child(0).name
	return target_layer

func get_target_block_layer() -> String:
	if block_layers.get_child_count() == 0:
		block_target_layer = ""
		return block_target_layer
	if block_target_layer == "" || !block_layers.get_node(block_target_layer):
		block_target_layer = block_layers.get_child(0).name
	return block_target_layer

func get_target_art_layer() -> String:
	if art_layers.get_child_count() == 0:
		art_target_layer = ""
		return art_target_layer
	if art_target_layer == "" || !art_layers.get_node(art_target_layer):
		art_target_layer = art_layers.get_child(0).name
	return art_target_layer


func add_layer(name: String) -> Layer:
	var layer = LAYER.instantiate()
	layer.name = name
	layer.layer = 10
	add_child(layer)
	if tile_config:
		layer.init(tile_config)
	return layer


func add_block_layer(name: String) -> BlockLayer:
	var layer = BLOCK_LAYER.instantiate()
	layer.name = name
	layer.layer = 10
	block_layers.add_child(layer)
	if tile_config:
		layer.init(tile_config)
	return layer

func add_art_layer(name: String) -> ArtLayer:
	var layer = ART_LAYER.instantiate()
	layer.name = name
	layer.layer = 10
	art_layers.add_child(layer)
	if tile_config:
		layer.init(tile_config)
	return layer


func remove_layer(name: String) -> void:
	var layer = get_node(name)
	if layer:
		remove_child(layer)
		layer.queue_free()


func remove_block_layer(name: String) -> void:
	var layer = block_layers.get_node(name)
	if layer:
		block_layers.remove_child(layer)
		layer.queue_free()


func remove_art_layer(name: String) -> void:
	var layer = art_layers.get_node(name)
	if layer:
		art_layers.remove_child(layer)
		layer.queue_free()


func calc_used_rect() -> void:
	for layer in block_layers.get_children():
		var tile_map_layer = layer.get_node("TileMapLayer")
		var map_used_rect = tile_map_layer.get_used_rect()
		if Game.game:
			Game.game.set_used_rect(layer.name, map_used_rect)
