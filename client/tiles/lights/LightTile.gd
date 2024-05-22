extends Tile
class_name LightTile

var LightDisplay: PackedScene = preload("res://tiles/lights/LightDisplay.tscn")
var display_color: Color = Color("ffffff")
var atlas_coords: Vector2i


func init():
	area.push_back(start_lightbreak)


func activate_tilemap(tilemap: TileMap):
	var coords_list = tilemap.get_used_cells_by_id(0, 0, atlas_coords)
	
	for coords in coords_list:
		
		# Add a light
		var light = LightDisplay.instantiate()
		var holder = tilemap.get_parent()
		var global_pos = tilemap.to_global((coords * Settings.tile_size) + Settings.tile_size_half)
		light.position = holder.to_local(global_pos)
		light.get_node("PointLight2D").color = display_color
		holder.add_child(light)


func start_lightbreak(player: Node2D, tilemap: Node2D, coords: Vector2i)->void:
	if player.lightbreak_from == coords:
		return
		
	var global_pos = tilemap.to_global((coords * Settings.tile_size) + Settings.tile_size_half)
	var dist = global_pos - player.position
	var target_velocity = dist * 3
	player.velocity = target_velocity
	if dist.length() < 5:
		if player.control_vector.length() != 0:
			player.lightbreak_direction = Vector2(player.control_vector)
			player.is_lightbreaking = true
		player.lightbreak_from = coords
		player.lightbreak_from_cooldown = 0.5
