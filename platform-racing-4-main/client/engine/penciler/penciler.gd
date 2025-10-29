extends Node2D

const CLEANUP_INTERVAL = 60  # 600 seconds (1 minutes)
var last_cleanup_time = 0
var tile_update_timestamps = {}
var layers: Layers
var bg: Node2D

@onready var layer_panel: Node2D = get_node_or_null("../UI/LayerPanel")
@onready var edit_cursors: Node2D = get_node_or_null("../EditorCursorLayer/EditorCursors")


func init(p_layers: Layers, p_bg, event_source) -> void:
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
		var layer = layers.get_node(event.layer_name)
		if layer.visible:
			var lines: Node2D = layers.get_node(event.layer_name + "/Lines")
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
		layer.get_node("TileMap").rotation_degrees = event.get("rotation", 0)
		layer.set_depth(event.get("depth", 10))
	
	if event.type == EditorEvents.RENAME_LAYER:
		var layer := layers.get_node(event.layer_name)
		layer.name = event.new_layer_name

	if event.type == EditorEvents.DELETE_LAYER:
		layers.remove_layer(event.name)

	if event.type == EditorEvents.ADD_USERTEXT:
		var layer = layers.get_node(event.layer_name)
		if layer.visible:
			var usertextboxes: Node2D = layers.get_node(event.layer_name + "/UserTextboxes")
			var usertextbox_scene: PackedScene = preload("res://engine/textbox/user_textbox.tscn")
			var usertextbox = usertextbox_scene.instantiate()
			usertextboxes.add_child(usertextbox)
			usertextbox.set_usertext_properties(event.usertext, event.font, event.font_size)
			usertextbox.position = Vector2(event.position.x, event.position.y)
			usertextbox.scale = Vector2(event.width, event.height)
			usertextbox.rotation = event.text_rotation
		
			# Handle additional properties if provided
			# if event.has("text_width") and event.has("text_height"):
			#	usertextbox.resize_text(event.text_width, event.text_height)
		
			# Configure mouse interaction based on editing mode
			if event.has("is_editing"):
				if event.is_editing:
					usertextbox.mouse_filter = 0 # Editable on click (click stops at text)
				else:
					usertextbox.mouse_filter = 2 # Not Editable on click (click passes through)
				usertextbox.disable_text_edits()

	if event.type == EditorEvents.ROTATE_LAYER:
		var layer = layers.get_node(event.layer_name)
		layer.get_node("TileMap").rotation_degrees = event.rotation

	if event.type == EditorEvents.LAYER_DEPTH:
		var layer = layers.get_node(event.layer_name)
		layer.set_depth(event.depth)

	if event.type == EditorEvents.VISIBLE_LAYER:
		var layer = layers.get_node(event.layer_name)
		layer.visible = event.visibility

	if event.type == EditorEvents.SET_BACKGROUND:
		if bg:
			if event.fade_color is Color:
				bg.set_bg(event.bg, event.fade_color)
			else:
				bg.set_bg(event.bg, Color(event.fade_color))


func _set_tile(event: Dictionary, coords: Vector2i, coords_key: String, new_timestamp: int = -1) -> void:
	var layer = layers.get_node(event.layer_name)
	if layer.visible:
		var tilemap: TileMap = layers.get_node(event.layer_name + "/TileMap")
		tilemap.set_cell(0, coords, 0, CoordinateUtils.to_atlas_coords(event.block_id))
	
	if new_timestamp != -1:
		tile_update_timestamps[coords_key] = new_timestamp
