extends Control
class_name Minimap

var game
var layers
var player


func init(game_scene):
	game = game_scene
	layers = game_scene.level_manager.layers
	player = game_scene.get_node("PlayerManager").get_character()
	
	for layer in self.layers.get_children():
		if layer is Layer:
			var minimap_layer = _create_minimap_layer(layer)
			add_child(minimap_layer)
	
	connect("resized", Callable(self, "_on_resized"))


func _on_resized():
	for child in get_children():
		if child is TileMapLayer:
			_update_minimap_layer_scale(child)


func _create_minimap_layer(layer):
	var tile_map_mini = TileMapLayer.new()
	tile_map_mini.name = layer.name
	
	tile_map_mini.tile_set = layer.tile_map.tile_set
	
	var used_cells = layer.tile_map.get_used_cells()
	for cell in used_cells:
		var source_id = layer.tile_map.get_cell_source_id(cell)
		var atlas_coords = layer.tile_map.get_cell_atlas_coords(cell)
		tile_map_mini.set_cell(cell, source_id, atlas_coords)

	_update_minimap_layer_scale(tile_map_mini)
	
	return tile_map_mini


func _update_minimap_layer_scale(minimap_layer: TileMapLayer):
	var used_rect = minimap_layer.get_used_rect()
	
	var scaleX = 1.0
	if used_rect.size.x > 0:
		scaleX = size.x / (used_rect.size.x * Settings.tile_size.x)
	
	var scaleY = 1.0
	if used_rect.size.y > 0:
		scaleY = size.y / (used_rect.size.y * Settings.tile_size.y)
		
	var effective_scale = min(scaleX, scaleY) * 0.9
	
	minimap_layer.scale = Vector2(effective_scale, effective_scale)
	
	var new_position = Vector2.ZERO
	new_position.x = (size.x - (used_rect.size.x * Settings.tile_size.x * effective_scale)) / 2
	new_position.y = (size.y - (used_rect.size.y * Settings.tile_size.y * effective_scale)) / 2
	
	new_position.x -= used_rect.position.x * Settings.tile_size.x * effective_scale
	new_position.y -= used_rect.position.y * Settings.tile_size.y * effective_scale
	
	minimap_layer.position = new_position


func _process(_delta):
	if not is_instance_valid(player):
		return
	
	for child in get_children():
		if child is TileMapLayer and child.name == game.get_current_player_layer():
			var player_marker = child.get_node_or_null("PlayerMarker")
			if not player_marker:
				player_marker = ColorRect.new()
				player_marker.name = "PlayerMarker"
				player_marker.color = Color.RED
				player_marker.size = Vector2(4, 4)
				child.add_child(player_marker)
			
			var player_pos_on_minimap = player.global_position / (Vector2(Settings.tile_size) * 10) # Adjust scale as needed
			player_marker.position = player_pos_on_minimap - child.position
