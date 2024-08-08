extends Node2D

const LAYER = preload("res://layers/Layer.tscn")


func decode(level: Dictionary) -> void:
	for encoded_layer in level.layers:
		var layer = LAYER.instantiate()
		layer.name = encoded_layer.name
		layer.get_node('TileMap').rotation_degrees = encoded_layer.get('rotation', 0)
		layer.follow_viewport_scale = encoded_layer.get('depth', 10) / 10
		layer.layer = encoded_layer.get('depth', 10)
		get_node("../Layers").add_child(layer)
		if encoded_layer.get("chunks"):
			decode_chunks(encoded_layer.chunks, layer.get_node("TileMap"))
		if encoded_layer.get("objects"):
			decode_lines(encoded_layer.objects, layer.get_node("Lines"))


func decode_chunks(chunks: Array, tilemap: TileMap) -> void:
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


func decode_lines(objects: Array, holder: Node2D) -> void:
	for object in objects:
		if !object.get("polyline"):
			continue
		var line = Line2D.new()
		line.position = Vector2(object.x, object.y)
		# line.points = object.polyline
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.default_color = Color("FFFFFF") # Color(object.properties.color)
		line.width = 10 # object.properties.thickness
		for point in str_to_var(object.polyline):
			line.add_point(Vector2(point.x, point.y))
		holder.add_child(line)