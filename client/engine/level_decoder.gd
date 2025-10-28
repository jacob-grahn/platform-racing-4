extends Node2D
class_name LevelDecoder

signal level_event

const LAYER = preload("res://layers/layer.tscn")


func decode(level: Dictionary, isEditing: bool, layers: Layers) -> void:
	GameConfig.clear_overrides()
	var properties = level.get("properties", {})
	if properties.has("game_config_overrides"):
		GameConfig.import_overrides(properties.game_config_overrides)

	print("LevelDecoder::decode: ", properties)
	# Emit background change event
	emit_signal("level_event", {
		"type": EditorEvents.SET_BACKGROUND,
		"bg": properties.get("background", ""),
		"fade_color": properties.get("fadeColor", "FFFFFF")
	})
	Jukebox.play(properties.get("music", ""))
	
	var level_layers = level.get("layers", [])
	if level_layers.is_empty():
		level_layers.append({"name": "Layer 1"})

	for encoded_layer in level_layers:
		# Emit add layer event
		emit_signal("level_event", {
			"type": EditorEvents.ADD_LAYER,
			"name": encoded_layer.name,
			"art_scale": encoded_layer.get("scale", 1.0),
			"rotation": encoded_layer.get("rotation", 0),
			"depth": encoded_layer.get("depth", 10)
		})
		
		if encoded_layer.get("chunks"):
			decode_chunks(encoded_layer.name, encoded_layer.chunks)
		if encoded_layer.get("lines"):
			decode_lines(encoded_layer.name, encoded_layer.lines)
		if encoded_layer.get("usertextboxobjects"):
			decode_usertextboxes(encoded_layer.name, encoded_layer.usertextboxobjects, isEditing)
		

func decode_chunks(encoded_layer_name: String, chunks: Array) -> void:
	for chunk in chunks:
		for i:int in chunk.data.size():
			var tile_id:int = chunk.data[i]
			if tile_id == 0:
				continue
			var coords = Vector2i(chunk.x + (i % int(chunk.width)), chunk.y + (i / int(chunk.width)))
			
			# Emit set tile event
			emit_signal("level_event", {
				"type": EditorEvents.SET_TILE,
				"layer_name": encoded_layer_name,
				"coords": {"x": coords.x, "y": coords.y},
				"block_id": tile_id
			})


func decode_lines(layer_name: String, objects: Array) -> void:
	for object in objects:
			
		var points_array = []
		for point in object.points:
			points_array.append({"x": point.x, "y": point.y})
			
		# Emit add line event
		var line_color
		if typeof(object.color) == TYPE_STRING:
			line_color = object.color
		else:
			line_color = Color(object.color[0], object.color[1], object.color[2], object.color[3]).to_html()

		emit_signal("level_event", {
			"type": EditorEvents.ADD_LINE,
			"layer_name": layer_name,
			"position": {"x": object.x, "y": object.y},
			"points": points_array,
			"color": line_color,
			"thickness": object.thickness
		})


func decode_usertextboxes(layer_name: String, usertextboxobjects: Array, isEditing: bool) -> void:
	for usertextboxobject in usertextboxobjects:
		
		#Failsafes for old text.
		if "font" not in usertextboxobject.keys():
			usertextboxobject.font = "res://fonts/Poetsen_One/PoetsenOne-Regular.ttf"
		
		if usertextboxobject.has("text_width") or usertextboxobject.has("text_height"):
			usertextboxobject.erase("text_width")
			usertextboxobject.get_or_add("width")
			usertextboxobject.erase("text_height")
			usertextboxobject.get_or_add("height")
			usertextboxobject.width = 1
			usertextboxobject.height = 1
		
		if "text_rotation" not in usertextboxobject.keys():
			usertextboxobject.text_rotation = 0
		
		# Emit add usertext event
		emit_signal("level_event", {
			"type": EditorEvents.ADD_USERTEXT,
			"layer_name": layer_name,
			"position": {"x": usertextboxobject.x, "y": usertextboxobject.y},
			"usertext": usertextboxobject.usertext,
			"font": usertextboxobject.font,
			"font_size": usertextboxobject.font_size,
			"width": usertextboxobject.width,
			"height": usertextboxobject.height,
			"text_rotation": usertextboxobject.text_rotation,
			"is_editing": isEditing
		})
