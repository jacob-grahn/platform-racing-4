extends Node2D

const LAYER = preload("res://layers/Layer.tscn")
var target_layer: String = ""
var tile_config: Tiles


func init(new_tile_config: Tiles) -> void:
	tile_config = new_tile_config
	for layer in get_children():
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


func add_layer(name: String) -> void:
	print("Layers::add_layer ", name)
	var layer = LAYER.instantiate()
	layer.name = name
	layer.layer = 10
	add_child(layer)
	layer.init(tile_config)


func remove_layer(name: String) -> void:
	var layer = get_node(name)
	if layer:
		remove_child(layer)
		layer.queue_free()
