extends Node2D
class_name MinimapDrawer

const MINIMAP_PREFAB = preload("res://pages/game/minimap.tscn")

var minimap_y_percentage = 0.2
var minimap_y_padding = 20
var layers: Layers
var editor_events: Node2D
var minimap_container: Control


# No longer need this since we connect in init
func _ready() -> void:
	pass


func init(p_layers: Layers, p_editor_events: Node2D, p_minimap_container: Control) -> void:
	layers = p_layers
	editor_events = p_editor_events
	minimap_container = p_minimap_container
	editor_events.connect("level_event", _on_level_event)


func _on_level_event(event: Dictionary) -> void:
	if event.type == EditorEvents.ADD_LAYER:
		_add_minimap_layer(event.name)
		
	elif event.type == EditorEvents.DELETE_LAYER:
		_remove_minimap_layer(event.name)
		
	elif event.type == EditorEvents.SET_TILE:
		_update_minimap_tile(event)
		
	elif event.type == EditorEvents.SELECT_LAYER:
		_show_selected_layer_minimap(event.layer_name)


func _add_minimap_layer(layer_name: String) -> void:
	if not minimap_container:
		return
		
	var minimap_instance = MINIMAP_PREFAB.instantiate()
	minimap_instance.name = layer_name
	minimap_container.add_child(minimap_instance)
	
	var current_player_layer = Session.get_current_player_layer()
	minimap_instance.visible = (layer_name == current_player_layer)


func _remove_minimap_layer(layer_name: String) -> void:
	if not minimap_container:
		return
		
	var minimap_instance = minimap_container.get_node_or_null(layer_name)
	if minimap_instance:
		minimap_instance.queue_free()


func _update_minimap_tile(event: Dictionary) -> void:
	if not minimap_container:
		return
		
	var minimap_instance = minimap_container.get_node_or_null(event.layer_name)
	if not minimap_instance:
		return
		
	var tile_map_mini = minimap_instance.get_node("TileMapMini")
	if not tile_map_mini:
		return
		
	var coords = Vector2i(event.coords.x, event.coords.y)
	var source_id = 0
	var atlas_coords = CoordinateUtils.to_atlas_coords(event.block_id)
	var alternative_tile = 0
	
	tile_map_mini.set_cell(0, coords, source_id, atlas_coords, alternative_tile)


func _show_selected_layer_minimap(layer_name: String) -> void:
	if not minimap_container:
		return
		
	for child in minimap_container.get_children():
		child.visible = (child.name == layer_name)


func update_minimap_view(layer_name: String) -> void:
	if not minimap_container:
		return
		
	var minimap_instance = minimap_container.get_node_or_null(layer_name)
	if not minimap_instance:
		return
		
	var tile_map_mini = minimap_instance.get_node("TileMapMini")
	if not tile_map_mini:
		return
	
	var layer_node = layers.get_node_or_null(layer_name)
	if not layer_node:
		return
		
	var tilemap = layer_node.get_node("TileMap")
	var map_used_rect = tilemap.get_used_rect()
	
	# Position the minimap
	tile_map_mini.position.y = -(map_used_rect.position.y) * Settings.tile_size.y
	tile_map_mini.position.x = -(map_used_rect.position.x) * Settings.tile_size.x
	
	# Calculate appropriate scale for the minimap
	var window_size = get_viewport().get_visible_rect().size
	var scaleX = window_size.x / (map_used_rect.size.x * Settings.tile_size.x)
	var scaleY = minimap_y_percentage * window_size.y / (map_used_rect.size.y * Settings.tile_size.y)
	var effective_scale = min(scaleX, scaleY) * 0.9
	var emptyX = window_size.x - (map_used_rect.size.x * Settings.tile_size.x * effective_scale)
	
	# Apply positioning and scaling
	minimap_instance.position.x += emptyX / 2
	minimap_instance.position.y += minimap_y_padding
	minimap_instance.scale = Vector2(effective_scale, effective_scale)
