extends Node2D

const LAYER = preload("res://layers/Layer.tscn")
@onready var bg: Node2D = get_node("../BG")
@onready var layers: Node2D = get_node("../Layers")
@onready var tile_map_mini: Node2D = get_node("../UI/Minimap/TileMapMini")
@onready var tile_map_control: Control = get_node("../UI/Minimap")

@onready var minimap_initial_position_x = tile_map_control.position.x
@onready var minimap_initial_position_y = tile_map_control.position.y
var minimap_y_percentage = 0.2
var minimap_y_padding = 20
	
func decode(level: Dictionary, isEditing: bool) -> void:
	var properties = level.get("properties", {})
	bg.set_bg(properties.get("background", ""))
	Jukebox.play(properties.get("music", ""))
	
	for encoded_layer in level.layers:
		var layer = LAYER.instantiate()
		layer.name = encoded_layer.name
		layers.add_child(layer)
		
		layer.art_scale = encoded_layer.get('scale', 1)
		layer.get_node('TileMap').rotation_degrees = encoded_layer.get('rotation', 0)
		layer.set_depth(encoded_layer.get('depth', 10))
		
		if encoded_layer.get("chunks"):
			decode_chunks(encoded_layer.chunks, layer.get_node("TileMap"), tile_map_mini)
		if encoded_layer.get("lines"):
			decode_lines(encoded_layer.lines, layer.get_node("Lines"))
		if encoded_layer.get("usertextboxobjects"):
			decode_usertextboxes(encoded_layer.usertextboxobjects, layer.get_node("UserTextboxes"), isEditing)
		

func decode_chunks(chunks: Array, tilemap: TileMap, tile_map_mini: TileMap) -> void:
	tile_map_mini.clear()
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
			
			var coords_mini = Vector2i(chunk.x + (i % int(chunk.width)), chunk.y + (i / int(chunk.width)))
			tile_map_mini.set_cell(0, coords_mini, source_id, atlas_coords, alternative_tile)
	
	var window_size = get_viewport().get_visible_rect().size
	var map_used_rect = tilemap.get_used_rect()
	
	tile_map_mini.position.y = -(map_used_rect.position.y) * Settings.tile_size.y
	tile_map_mini.position.x = -(map_used_rect.position.x) * Settings.tile_size.x
	
	var scaleX = window_size.x / (map_used_rect.size.x * Settings.tile_size.x)
	var scaleY = minimap_y_percentage * window_size.y / (map_used_rect.size.y * Settings.tile_size.y)
	var effective_scale = min(scaleX, scaleY) * 0.9
	var emptyX = window_size.x - (map_used_rect.size.x * Settings.tile_size.x * effective_scale)
	
	tile_map_control.position.x = minimap_initial_position_x + (emptyX / 2)
	tile_map_control.position.y = minimap_initial_position_y + minimap_y_padding
	tile_map_control.scale = Vector2(effective_scale, effective_scale)

func decode_lines(objects: Array, holder: Node2D) -> void:
	for object in objects:
		if !object.get("points"):
			continue
		var line = Line2D.new()
		line.position = Vector2(object.x, object.y)
		line.add_point(Vector2(0, 0))
		for point in object.points:
			line.add_point(Vector2(point.x, point.y))
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.default_color = Color(object.color)
		line.width = object.thickness
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
