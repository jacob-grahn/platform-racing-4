extends Node2D

const LAYER = preload("res://pages/editor/Layer.tscn")


func decode(level: Dictionary) -> void:
	var layer = LAYER.instantiate()
	layer.name = "Layer 1"
	get_node("../Layers").add_child(layer)
	var tilemap = layer.get_node("TileMap")
	
	var tile_layer = level.layers[0]
	var chunks = tile_layer.chunks
	for chunk in chunks:
		for i:int in chunk.data.size():
			var tile_id:int = chunk.data[i]
			if tile_id == 0:
				continue
			var coords = Vector2i(chunk.x + (i % int(chunk.width)), chunk.y + (i / int(chunk.width)))
			var source_id = 0
			var atlas_coords = Helpers.to_atlas_coords(tile_id)
			var alternative_tile = 0
			tilemap.set_cell(0, coords, source_id, atlas_coords, alternative_tile)
