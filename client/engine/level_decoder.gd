extends Node2D

signal level_event

const LAYER = preload("res://layers/layer.tscn")


func decode(level: Dictionary, isEditing: bool, layers: Layers) -> void:
	var properties = level.get("properties", {})
	# Emit background change event
	emit_signal("level_event", {
		"type": EditorEvents.SET_BACKGROUND,
		"bg": properties.get("background", "")
	})
	Jukebox.play(properties.get("music", ""))
	
	for encoded_layer in level.layers:
		print("decode layer: ", encoded_layer.name)
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
		if !object.get("points"):
			continue
			
		var points_array = []
		for point in object.points:
			points_array.append({"x": point.x, "y": point.y})
			
		# Emit add line event
		emit_signal("level_event", {
			"type": EditorEvents.ADD_LINE,
			"layer_name": layer_name,
			"position": {"x": object.x, "y": object.y},
			"points": points_array,
			"color": object.color,
			"thickness": object.thickness
		})


func decode_usertextboxes(layer_name: String, usertextboxobjects: Array, isEditing: bool) -> void:
	for usertextboxobject in usertextboxobjects:
		if "font" not in usertextboxobject.keys(): #Failsafe for old text. May be removed in future.
			usertextboxobject.font = "res://fonts/Poetsen_One/PoetsenOne-Regular.ttf"
			
		# Emit add usertext event
		emit_signal("level_event", {
			"type": EditorEvents.ADD_USERTEXT,
			"layer_name": layer_name,
			"position": {"x": usertextboxobject.x, "y": usertextboxobject.y},
			"usertext": usertextboxobject.usertext,
			"font": usertextboxobject.font,
			"font_size": usertextboxobject.font_size,
			"text_width": usertextboxobject.text_width,
			"text_height": usertextboxobject.text_height,
			"is_editing": isEditing
		})
