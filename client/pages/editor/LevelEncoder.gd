extends Node2D

var chunk_size = Vector2i(10, 10)


func encode() -> Dictionary:
	var level = {
		"layers": []
	}
	var layers: Node2D = get_node("../Layers")
	for group_layer in layers.get_children():
		var tile_layer = {
			"name": group_layer.name,
			"chunks": encode_chunks(group_layer.get_node("TileMap")),
			"objects": encode_lines(group_layer.get_node("Lines")),
			"usertextboxobjects": encode_usertext(group_layer.get_node("UserTextboxes")),
			"rotation": group_layer.get_node("TileMap").rotation_degrees,
			"depth": round(group_layer.follow_viewport_scale * 10)
		}
		level.layers.push_back(tile_layer)
	return level


func decode():
	pass


func encode_chunks(tilemap: TileMap) -> Array:
	var chunk_map = {}
	var chunks = []
	var used_coords = tilemap.get_used_cells(0)
	for coords in used_coords:
		var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
		var block_id = Helpers.to_block_id(atlas_coords)
		var chunk_coords: Vector2i = Vector2i((Vector2(coords) / Vector2(chunk_size)).floor())
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
			chunks.push_back(chunk)
			chunk_map[chunk_name] = chunk
		chunk.data[chunk_data_index] = block_id
	return chunks


func encode_lines(node: Node2D) -> Array:
	var objects = []
	for line: Line2D in node.get_children():
		var object = {
			"x": line.position.x,
			"y": line.position.y,
			"polyline": line.points,
			"properties": {
				"color": "FFFFFF",
				"thickness": 10
			}
		}
		objects.push_back(object)
	return objects


func encode_usertext(node: Node2D) -> Array:
	var usertextboxobjects = []
	for usertextbox: Label in node.get_children():
		print("textbox save")
		var usertextboxobject = {
			"x": usertextbox.position.x,
			"y": usertextbox.position.y,
			"usertext": usertextbox.text,
			#"font": usertextbox.get_theme_font("usertext_font"),
			"font_size": usertextbox.get("theme_override_font_sizes/font_size"),
			"autowrap_mode": usertextbox.autowrap_mode,
			"text_width": usertextbox.size.x
		}
		usertextboxobjects.push_back(usertextboxobject)
	return usertextboxobjects
