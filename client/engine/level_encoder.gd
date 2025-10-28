extends Node2D
class_name LevelEncoder

var chunk_size = Vector2i(10, 10)

func encode(layers: Node2D, bg: Node2D) -> Dictionary:
	var level = {
		"layers": [],
		"properties": {
			# "title": LevelEditor.current_level,
			# "description": LevelEditor.current_description,
			"background": bg.id,
			"music": Jukebox.song_id,
			"game_config_overrides": GameConfig.export_overrides()
		}
	}
	for group_layer in layers.get_children():
		if group_layer is Layer:
			var tile_layer = {
				"name": group_layer.name,
				"chunks": encode_chunks(group_layer.get_node("TileMapLayer")),
				"lines": encode_lines(group_layer.get_node("Lines")),
				"usertextboxobjects": encode_usertext(group_layer.get_node("UserTextboxes")),
				"rotation": group_layer.get_node("TileMapLayer").rotation_degrees,
				"depth": group_layer.depth
			}
			level.layers.push_back(tile_layer)
	return level


func encode_chunks(tile_map_layer: TileMapLayer) -> Array:
	var chunk_map = {}
	var chunks = []
	var used_coords = tile_map_layer.get_used_cells()
	for coords in used_coords:
		var atlas_coords = tile_map_layer.get_cell_atlas_coords(coords)
		var block_id = CoordinateUtils.to_block_id(atlas_coords)
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
	var lines = []
	
	for line: Line2D in node.get_children():
		var pointObjects = []
		for point in line.points:
			pointObjects.push_back({"x": point.x, "y": point.y})
		var lineData = {
			"x": line.position.x,
			"y": line.position.y,
			"points": pointObjects.slice(1, len(pointObjects) - 1), # the first point should always be 0,0, we can leave it out
			"color": line.default_color,
			"thickness": line.width
		}
		lines.push_back(lineData)
	return lines


func encode_usertext(node: Node2D) -> Array:
	var usertextboxobjects = []
	for usertextbox: Control in node.get_children():
		var usertextboxobject = {
			"x": usertextbox.position.x,
			"y": usertextbox.position.y,
			"usertext": usertextbox.get_node("UserText").text,
			"font": usertextbox.usertext_font,
			"font_size": usertextbox.get_node("UserText").get("theme_override_font_sizes/font_size"),
			"width": usertextbox.get_node("UserText").scale.x,
			"height": usertextbox.get_node("UserText").scale.y,
			"text_rotation": usertextbox.rotation
		}
		usertextboxobjects.push_back(usertextboxobject)
	return usertextboxobjects
