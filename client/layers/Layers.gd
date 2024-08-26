extends Node2D


func init(tiles: Tiles) -> void:
	for layer in get_children():
		layer.init(tiles)


func clear() -> void:
	for layer in get_children():
		layer.queue_free()
