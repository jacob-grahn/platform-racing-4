extends Node2D
class_name LevelDecoder

signal level_event

const LAYER = preload("res://layers/layer.tscn")
const BLOCK_LAYER = preload("res://layers/blocklayer.tscn")
const ART_LAYER = preload("res://layers/artlayer.tscn")


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
	# Emit music change event
	emit_signal("level_event", {
		"type": EditorEvents.SET_SONG_ID,
		"song_id": properties.get("music", "")
	})
	#Jukebox.play(properties.get("music", ""))
	
	# Failsafe for levels that don't have block_layers or art_layers.
	if level.has("layers"):
		var level_layers = level.get("layers", [])
		if !level_layers.is_empty():
			for encoded_layer in level_layers:
				var chunks = encoded_layer.get("chunks", [])
				if !chunks.is_empty():
					# Emit add block layer event
					emit_signal("level_event", {
						"type": EditorEvents.ADD_BLOCK_LAYER,
						"name": encoded_layer.name,
						"tile_map_rotation": encoded_layer.get("rotation", 0),
						"z_axis": encoded_layer.get("depth", 10)
					})
					if encoded_layer.get("chunks"):
						decode_chunks(encoded_layer.name, encoded_layer.chunks)
			for encoded_layer in level_layers:
				var lines = encoded_layer.get("lines", [])
				var texts = encoded_layer.get("texts", [])
				if !lines.is_empty() or !texts.is_empty():
					# Emit add art layer event
					emit_signal("level_event", {
						"type": EditorEvents.ADD_ART_LAYER,
						"name": encoded_layer.name,
						"art_scale": encoded_layer.get("scale", 1.0),
						"art_rotation": encoded_layer.get("rotation", 0),
						"depth": encoded_layer.get("depth", 10),
						"z_axis": encoded_layer.get("depth", 10),
						"alpha": 100
					})
					if encoded_layer.get("lines"):
						decode_lines(encoded_layer.name, encoded_layer.lines)
					if encoded_layer.get("usertextboxobjects"):
						decode_texts(encoded_layer.name, encoded_layer.usertextboxobjects, isEditing)
		level.get_or_add("block_layers", [])
		level.get_or_add("art_layers", [])
		var level_block_layers = level.get("block_layers", [])
		if level_block_layers.is_empty():
			level_block_layers.append({"name": "Layer 1"})
		var level_art_layers = level.get("art_layers", [])
		if level_art_layers.is_empty():
			level_art_layers.append({"name": "Layer 1"})
		level.erase("layers")
	else:
		var level_block_layers = level.get("block_layers", [])
		if level_block_layers.is_empty():
			level_block_layers.append({"name": "Layer 1"})
		
		for encoded_block_layer in level_block_layers:
			# Emit add layer event
			emit_signal("level_event", {
				"type": EditorEvents.ADD_BLOCK_LAYER,
				"name": encoded_block_layer.name,
				"tile_map_rotation": encoded_block_layer.get("tile_map_rotation", 0),
				"z_axis": encoded_block_layer.get("z_axis", 10)
			})
		
			if encoded_block_layer.get("chunks"):
				decode_chunks(encoded_block_layer.name, encoded_block_layer.chunks)
		
		
		var level_art_layers = level.get("art_layers", [])
		if level_art_layers.is_empty():
			level_art_layers.append({"name": "Layer 1"})
		
		for encoded_art_layer in level_art_layers:
			# Emit add layer event
			emit_signal("level_event", {
				"type": EditorEvents.ADD_ART_LAYER,
				"name": encoded_art_layer.name,
				"art_scale": encoded_art_layer.get("scale", 1.0),
				"art_rotation": encoded_art_layer.get("art_rotation", 0),
				"depth": encoded_art_layer.get("depth", 10),
				"z_axis": encoded_art_layer.get("z_axis", 10),
				"alpha": encoded_art_layer.get("alpha", 100)
			})
		
			if encoded_art_layer.get("lines"):
				decode_lines(encoded_art_layer.name, encoded_art_layer.lines)
			if encoded_art_layer.get("texts"):
				decode_texts(encoded_art_layer.name, encoded_art_layer.texts, isEditing)
		

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
				"block_id": tile_id,
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


func decode_texts(layer_name: String, textboxobjects: Array, isEditing: bool) -> void:
	for textboxobject in textboxobjects:
		
		#Failsafes for old text.
		
		# usertextbox renamed to text (or textbox)
		if textboxobject.has("usertext"): 
			textboxobject.get_or_add("text")
			textboxobject.text = textboxobject.usertext
			textboxobject.erase("usertext")
		
		if "font" not in textboxobject.keys():
			textboxobject.font = "res://fonts/Poetsen_One/PoetsenOne-Regular.ttf"
		
		if textboxobject.has("text_width") or textboxobject.has("text_height"):
			textboxobject.erase("text_width")
			textboxobject.get_or_add("width")
			textboxobject.erase("text_height")
			textboxobject.get_or_add("height")
			textboxobject.width = 1
			textboxobject.height = 1
		
		if "text_rotation" not in textboxobject.keys():
			textboxobject.text_rotation = 0
		
		# Emit add usertext event
		emit_signal("level_event", {
			"type": EditorEvents.ADD_TEXT,
			"layer_name": layer_name,
			"position": {"x": textboxobject.x, "y": textboxobject.y},
			"text": textboxobject.text,
			"font": textboxobject.font,
			"font_size": textboxobject.font_size,
			"width": textboxobject.width,
			"height": textboxobject.height,
			"text_rotation": textboxobject.text_rotation,
			"dont_grab_focus": true
		})
