extends Node2D

var target_layer: String = ""


func init(tiles: Tiles) -> void:
	for layer in get_children():
		layer.init(tiles)


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
