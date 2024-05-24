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
	# avoid drawing the player into the same light again too soon
	if player.lightbreak_src_tile == coords:
		return
	
	# draw the player into the center of the light
	var global_pos = tilemap.to_global((coords * Settings.tile_size) + Settings.tile_size_half)
	var game_pos = player.get_parent().to_local(global_pos)
	var dist = game_pos - player.position
	var target_velocity = dist * 3
	player.velocity = target_velocity
	player.light.color = display_color
	player.lightbreak_windup += player.get_physics_process_delta_time() * 2
	
	# get into the lightbreak faster if you release dir keys and hit the direction you want
	if player.control_vector.length() == 0:
		player.lightbreak_input_primed = true
	if player.control_vector.length() != 0 && player.lightbreak_input_primed:
		player.lightbreak_direction = Vector2(player.control_vector)
		player.lightbreak_src_tile = coords
		player.lightbreak_input_primed = false
		player.lightbreak_windup = 0.1
		return
	
	# at the light timeout, either go in the direction that is being pressed or drop out
	if player.lightbreak_windup >= 1:
		if player.control_vector.length() != 0:
			player.lightbreak_direction = Vector2(player.control_vector)
			player.lightbreak_windup = 0.1
		else:
			player.lightbreak_direction = Vector2(0, 0)
		player.lightbreak_src_tile = coords
		player.lightbreak_input_primed = false
		
