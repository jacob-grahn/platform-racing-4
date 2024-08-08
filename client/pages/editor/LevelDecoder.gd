extends Node2D

const LAYER = preload("res://layers/Layer.tscn")


func decode(level: Dictionary, isEditing: bool) -> void:
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
		for point in str_to_var(object.polyline):
			line.add_point(Vector2(point.x, point.y))
		holder.add_child(line)


func decode_usertextboxes(usertextboxobjects: Array, holder: Node2D, isEditing: bool) -> void:
	for usertextboxobject in usertextboxobjects:
		var usertextbox = TextEdit.new()
		holder.add_child(usertextbox)
		usertextbox.position = Vector2(usertextboxobject.x, usertextboxobject.y)
		usertextbox.text = usertextboxobject.usertext
		usertextbox.wrap_mode = usertextboxobject.wrap_mode
		usertextbox.autowrap_mode = usertextboxobject.autowrap_mode
		usertextbox.set("theme_override_fonts/font", load("res://fonts/Poetsen_One/PoetsenOne-Regular.ttf"))
		usertextbox.set("theme_override_font_sizes/font_size", usertextboxobject.font_size)
		var usertextbox_bg = StyleBoxFlat.new()
		usertextbox.set("theme_override_styles/normal", usertextbox_bg)
		usertextbox_bg.set_bg_color(str_to_var(usertextboxobject.background_color))
		usertextbox.size.x = usertextboxobject.text_width
		usertextbox.size.y = usertextboxobject.text_height
		if isEditing:
			usertextbox.mouse_filter = 0 #Editable on click (click stops at text)
		else:
			usertextbox.mouse_filter = 2 #Not Editable on click (click passes through)
		usertextbox.context_menu_enabled = false
