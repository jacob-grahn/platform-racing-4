extends Node2D

const CLEANUP_INTERVAL = 60  # 600 seconds (1 minutes)
var last_cleanup_time = 0
var tile_update_timestamps = {}
var layers: Layers
var bg: Node2D
var layer_panel: Node2D

func init(p_layers: Layers, p_bg, event_source, p_layer_panel: Node2D) -> void:
	layer_panel = p_layer_panel
	layers = p_layers
	bg = p_bg
	event_source.connect("level_event", _on_level_event)


func _process(delta: float) -> void:
	var current_time = Time.get_unix_time_from_system()
	if current_time - last_cleanup_time >= CLEANUP_INTERVAL:
		_cleanup_old_timestamps()
		last_cleanup_time = current_time


func _cleanup_old_timestamps() -> void:
	var current_time = Time.get_unix_time_from_system()
	for key in tile_update_timestamps.keys():
		if current_time - tile_update_timestamps[key] > CLEANUP_INTERVAL:
			tile_update_timestamps.erase(key)


func _on_level_event(event: Dictionary) -> void:
	if event.type == EditorEvents.SET_TILE:
		var coords = Vector2i(event.coords.x, event.coords.y)
		var coords_key = str(coords.x) + "_" + str(coords.y)
		
		if event.has("timestamp"):
			var new_timestamp = event.timestamp
			
			if not tile_update_timestamps.has(coords_key) or tile_update_timestamps[coords_key] < new_timestamp:
				_set_tile(event, coords, coords_key, new_timestamp)
		else:
			_set_tile(event, coords, coords_key)

	if event.type == EditorEvents.ADD_LINE:
		var layer = layers.art_layers.get_node(event.layer_name)
		if layer.visible:
			var lines: Node2D = layers.art_layers.get_node(event.layer_name + "/Lines")
			var line = Line2D.new()
			lines.add_child(line)
			line.end_cap_mode = Line2D.LINE_CAP_ROUND
			line.begin_cap_mode = Line2D.LINE_CAP_ROUND
			line.position = Vector2(event.position.x, event.position.y)
		
			var converted_points = []
		
			# if the first point is not 0,0, add 0,0 as the first point
			if len(event.points) == 0 || event.points[0].x != 0 || event.points[0].y != 0:
				converted_points.append(Vector2.ZERO)
		
			# convert point objects into Vector2
			for point_dict in event.points:
				converted_points.append(Vector2(point_dict.x, point_dict.y))
		
			# if there is only one point, add another one. Need at least two points to draw a line
			if len(converted_points) == 1:
				converted_points.append(converted_points[0] + Vector2(0.1, 0.1))
		
			#
			line.points = converted_points
		
			# Set line color and width if provided in the event
			if event.has("color"):
				if event.color is Color:
					line.default_color = event.color
				else:
					line.default_color = Color(event.color)
			if event.has("width"):
				line.width = event.width
			if event.has("thickness"):
				line.width = event.thickness

	if event.type == EditorEvents.ADD_LAYER:
		var layer := layers.add_layer(event.name)
		layer.art_scale = event.get("art_scale", 1.0)
		layer.get_node("TileMapLayer").rotation_degrees = event.get("rotation", 0)
		layer.set_depth(event.get("depth", 10))
	
	if event.type == EditorEvents.ADD_BLOCK_LAYER:
		var layer := layers.add_block_layer(event.name)
		layer.set_block_layer_rotation(event.get("tile_map_rotation", 0))
		layer.set_z_axis(event.get("z_axis", 10))
	
	if event.type == EditorEvents.ADD_ART_LAYER:
		var layer := layers.add_art_layer(event.name)
		layer.art_scale = event.get("art_scale", 1.0)
		layer.set_art_rotation(event.get("art_rotation", 10))
		layer.set_depth(event.get("depth", 10))
		layer.set_z_axis(event.get("z_axis", 10))
		layer.set_art_alpha(event.get("alpha", 100))
	
	if event.type == EditorEvents.RENAME_LAYER:
		var layer := layers.get_node(event.layer_name)
		layer.name = event.new_layer_name
	
	if event.type == EditorEvents.RENAME_BLOCK_LAYER:
		var layer := layers.block_layers.get_node(event.layer_name)
		layer.name = event.new_layer_name
	
	if event.type == EditorEvents.RENAME_ART_LAYER:
		var layer := layers.art_layers.get_node(event.layer_name)
		layer.name = event.new_layer_name

	if event.type == EditorEvents.DELETE_LAYER:
		layers.remove_layer(event.name)
	
	if event.type == EditorEvents.DELETE_BLOCK_LAYER:
		layers.remove_block_layer(event.name)
	
	if event.type == EditorEvents.DELETE_ART_LAYER:
		layers.remove_art_layer(event.name)

	if event.type == EditorEvents.ADD_TEXT:
		var layer = layers.art_layers.get_node(event.layer_name)
		if layer.visible:
			var textboxes: Node2D = layers.art_layers.get_node(event.layer_name + "/Texts")
			var textbox_scene: PackedScene = preload("res://engine/textbox/textbox.tscn")
			var textbox = textbox_scene.instantiate()
			var grab_focus: bool
			if event.has("dont_grab_focus") and event.dont_grab_focus:
				grab_focus = false
			else:
				grab_focus = true
			textboxes.add_child(textbox)
			textbox.set_text_properties(event.text, event.font, event.font_size, Vector2(event.width, event.height), grab_focus)
			textbox.position = Vector2(event.position.x, event.position.y)
			textbox.rotation = event.text_rotation
		
			# Configure mouse interaction based on editing mode
			if event.has("is_editing"):
				if event.is_editing:
					textbox.mouse_filter = 0 # Editable on click (click stops at text)
				else:
					textbox.mouse_filter = 2 # Not Editable on click (click passes through)
				textbox.disable_text_edits()

	if event.type == EditorEvents.SET_LAYER_Z_AXIS:
		var layer = layers.get_node(event.layer_name)
		layer.z_axis = event.z_axis
	
	if event.type == EditorEvents.SET_BLOCK_LAYER_Z_AXIS:
		var layer = layers.block_layers.get_node(event.layer_name)
		layer.set_z_axis(event.z_axis)
	
	if event.type == EditorEvents.SET_ART_LAYER_Z_AXIS:
		var layer = layers.art_layers.get_node(event.layer_name)
		layer.z_axis = event.z_axis
	
	if event.type == EditorEvents.SET_LAYER_DEPTH:
		var layer = layers.get_node(event.layer_name)
		layer.set_depth(event.depth)
	
	if event.type == EditorEvents.SET_ART_LAYER_DEPTH:
		var layer = layers.art_layers.get_node(event.layer_name)
		layer.set_depth(event.depth)

	if event.type == EditorEvents.SET_LAYER_ROTATION:
		var layer = layers.get_node(event.layer_name)
		layer.get_node("TileMapLayer").rotation_degrees = event.rotation
	
	if event.type == EditorEvents.SET_BLOCK_LAYER_ROTATION:
		var layer = layers.block_layers.get_node(event.layer_name)
		layer.set_block_layer_rotation(event.tile_map_rotation)
	
	if event.type == EditorEvents.SET_ART_LAYER_ROTATION:
		var layer = layers.art_layers.get_node(event.layer_name)
		layer.get_node("Stamps").rotation_degrees = event.rotation
		layer.get_node("Lines").rotation_degrees = event.rotation
		layer.get_node("Texts").rotation_degrees = event.rotation
	
	if event.type == EditorEvents.SET_LAYER_ALPHA:
		var layer = layers.get_node(event.layer_name)
		layer.alpha = event.alpha
	
	if event.type == EditorEvents.SET_ART_LAYER_ALPHA:
		var layer = layers.art_layers.get_node(event.layer_name)
		layer.alpha = event.alpha

	if event.type == EditorEvents.SET_BACKGROUND:
		if bg:
			if event.fade_color is Color:
				bg.set_bg(event.bg, event.fade_color)
			else:
				bg.set_bg(event.bg, Color(event.fade_color))
	
	if event.type == EditorEvents.SET_SONG_ID:
		if bg:
			bg.set_song_id(event.song_id)


func _set_tile(event: Dictionary, coords: Vector2i, coords_key: String, new_timestamp: int = -1) -> void:
	var layer = layers.block_layers.get_node(event.layer_name)
	if layer.visible:
		var tile_map_layer: TileMapLayer = layers.block_layers.get_node(event.layer_name + "/TileMapLayer")
		tile_map_layer.set_cell(coords, 0, CoordinateUtils.to_atlas_coords(event.block_id))
	
	if new_timestamp != -1:
		tile_update_timestamps[coords_key] = new_timestamp
