extends Node2D

signal level_event

const LAYER = preload("res://layers/layer.tscn")
@onready var bg: Node2D = get_node("../BG")
#@onready var minimap_container: Control = get_node("../UI/Minimaps")
@onready var editor_events: Node2D = get_node("../EditorEvents")

const MINIMAP_PREFAB = preload("res://pages/game/minimap.tscn")

#var minimap_y_percentage = 0.2
#var minimap_y_padding = 20


func decode(level: Dictionary, isEditing: bool, layers: Layers) -> void:
	var properties = level.get("properties", {})
	if bg:
		# Emit background change event
		emit_signal("level_event", {
			"type": EditorEvents.SET_BACKGROUND,
			"bg": properties.get("background", "")
		})
	Jukebox.play(properties.get("music", ""))
	
	# var current_player_layer = Session.get_current_player_layer()
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
		
		#var minimap_instance
		#if minimap_container:
		#	minimap_instance = MINIMAP_PREFAB.instantiate()
		#	minimap_instance.name = encoded_layer.name
		#	minimap_container.add_child(minimap_instance)
		#	minimap_instance.visible = (encoded_layer.name == current_player_layer)
		
		if encoded_layer.get("chunks"):
			decode_chunks(encoded_layer.name, encoded_layer.chunks)
		if encoded_layer.get("lines"):
			decode_lines(encoded_layer.name, encoded_layer.lines)
		if encoded_layer.get("usertextboxobjects"):
			decode_usertextboxes(encoded_layer.name, encoded_layer.usertextboxobjects, isEditing)
		

func decode_chunks(encoded_layer_name: String, chunks: Array) -> void: # tilemap: TileMap, minimap_instance: Control
	#var tile_map_mini
	#if minimap_instance:
	#	tile_map_mini = minimap_instance.get_node("TileMapMini")
	#	tile_map_mini.clear()
		
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
			
			# Handle minimap separately since it's not part of the event system
			#if tile_map_mini:
			#	var source_id = 0
			#	var atlas_coords = Helpers.to_atlas_coords(tile_id)
			#	var alternative_tile = 0
			#	tile_map_mini.set_cell(0, coords, source_id, atlas_coords, alternative_tile)
	
	#var window_size = get_viewport().get_visible_rect().size
	#var map_used_rect = tilemap.get_used_rect()
	#Session.set_used_rect(encoded_layer_name, map_used_rect)
	
	#if tile_map_mini:
	#	tile_map_mini.position.y = -(map_used_rect.position.y) * Settings.tile_size.y
	#	tile_map_mini.position.x = -(map_used_rect.position.x) * Settings.tile_size.x
	
	#var scaleX = window_size.x / (map_used_rect.size.x * Settings.tile_size.x)
	#var scaleY = minimap_y_percentage * window_size.y / (map_used_rect.size.y * Settings.tile_size.y)
	#var effective_scale = min(scaleX, scaleY) * 0.9
	#var emptyX = window_size.x - (map_used_rect.size.x * Settings.tile_size.x * effective_scale)
	
	#if minimap_instance:
	#	minimap_instance.position.x += emptyX / 2
	#	minimap_instance.position.y += minimap_y_padding
	#	minimap_instance.scale = Vector2(effective_scale, effective_scale)


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
