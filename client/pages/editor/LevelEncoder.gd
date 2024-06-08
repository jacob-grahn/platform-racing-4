extends Node2D

var chunk_size = Vector2i(10, 10)


func encode() -> Dictionary:
	var level = {
		"layers": []
	}
	var layers: Node2D = get_node("../Layers")
	for group_layer in layers.get_children():
		var tile_layer = {
			"chunks": []
		}
		var chunk_map = {}
		var tilemap = group_layer.get_node("TileMap")
		var used_coords = tilemap.get_used_cells(0)
		for coords in used_coords:
			var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
			var block_id = Helpers.to_block_id(atlas_coords)
			var chunk_coords = coords / chunk_size
			var chunk_data_coords = coords - (chunk_coords * chunk_size)
			var chunk_name = str(chunk_coords.x) + "," + str(chunk_coords.y)
			var chunk_data_index = (chunk_data_coords.y * chunk_size.x) + chunk_data_coords.x
			var existing_chunk = chunk_map.get(chunk_name)
			var chunk: Dictionary
			if existing_chunk:
				chunk = existing_chunk
			else:
				var data = []
				data.resize(chunk_size.x * chunk_size.y)
				data.fill(0)
				chunk = {
					"x": chunk_coords.x * chunk_size.x,
					"y": chunk_coords.y * chunk_size.y,
					"width": chunk_size.x,
					"height": chunk_size.y,
					"data": data
				}
				tile_layer.chunks.push_back(chunk)
				chunk_map[chunk_name] = chunk
			chunk.data[chunk_data_index] = block_id
		level.layers.push_back(tile_layer)
	print(level)
	return level


func decode():
	pass
