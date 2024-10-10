extends Node2D

const LAYER = preload("res://layers/Layer.tscn")
@onready var bg: Node2D = get_node("../BG")
@onready var layers: Node2D = get_node("../Layers")


func decode(level: Dictionary, isEditing: bool) -> void:
	var properties = level.get("properties", {})
	bg.set_bg(properties.get("background", ""))
	Jukebox.play(properties.get("music", ""))
	
	for encoded_layer in level.layers:
		var layer = LAYER.instantiate()
		layer.name = encoded_layer.name
		layer.get_node('TileMap').rotation_degrees = encoded_layer.get('rotation', 0)
		layer.follow_viewport_scale = encoded_layer.get('depth', 10) / 10
		layer.layer = encoded_layer.get('depth', 10)
		layers.add_child(layer)
		if encoded_layer.get("chunks"):
			decode_chunks(encoded_layer.chunks, layer.get_node("TileMap"))
		if encoded_layer.get("objects"):
			decode_lines(encoded_layer.objects, layer.get_node("Lines"))
		if encoded_layer.get("usertextboxobjects"):
			decode_usertextboxes(encoded_layer.usertextboxobjects, layer.get_node("UserTextboxes"), isEditing)


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
		var polyline
		if typeof(object.polyline) == 4: #If the line was saved as a string (For levels made in PR4)
			polyline = str_to_var(object.polyline)
		else: #For imported levels from PR2 (Saved as an array already)
			polyline = object.polyline
		for point in polyline:
			line.add_point(Vector2(point.x, point.y))
		holder.add_child(line)


func decode_usertextboxes(usertextboxobjects: Array, holder: Node2D, isEditing: bool) -> void:
	for usertextboxobject in usertextboxobjects:
		var usertextbox_scene: PackedScene = preload("res://pages/editor/menu/UserTextbox.tscn")
		var usertextbox = usertextbox_scene.instantiate()
		if "font" not in usertextboxobject.keys(): #Failsafe for old text. May be removed in future.
			usertextboxobject.font = "res://fonts/Poetsen_One/PoetsenOne-Regular.ttf"
		usertextbox.set_usertext_properties(usertextboxobject.usertext, usertextboxobject.font, usertextboxobject.font_size)
		holder.add_child(usertextbox)
		usertextbox.position = Vector2(usertextboxobject.x, usertextboxobject.y)
		usertextbox.resize_text(usertextboxobject.text_width, usertextboxobject.text_height)
		usertextbox.disable_text_edits()

		if isEditing:
			usertextbox.mouse_filter = 0 #Editable on click (click stops at text)
		else:
			usertextbox.mouse_filter = 2 #Not Editable on click (click passes through)
