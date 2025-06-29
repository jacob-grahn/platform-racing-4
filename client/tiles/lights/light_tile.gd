extends Tile
class_name LightTile

const SUN = "sun"
const MOON = "moon"
const FIREFLY = "firefly"

var LightDisplay: PackedScene = preload("res://tiles/lights/light_display.tscn")
var display_color: Color = Color("ffffff")
var atlas_coords: Vector2i
var lightbreak_type: String


func init():
	matter_type = Tile.GAS
	area.push_back(charge_lightbreak)


func activate_tilemap(tilemap: TileMapLayer) -> void:
	var coords_list = tilemap.get_used_cells_by_id(0, atlas_coords)
	
	for coords in coords_list:
		
		# Add a light
		var light = LightDisplay.instantiate()
		var holder = tilemap.get_parent()
		light.position = (coords * Settings.tile_size) + Settings.tile_size_half
		light.get_node("PointLight2D").color = display_color
		holder.add_child(light)


func charge_lightbreak(player: Node2D, tilemap: Node2D, coords: Vector2i)->void:
	# avoid drawing the player into the same light again too soon
	if player.lightbreak.src_tile == coords:
		return
	
	# draw the player into the center of the light
	var global_pos = tilemap.to_global((coords * Settings.tile_size) + Settings.tile_size_half)
	var game_pos = player.get_parent().to_local(global_pos)
	var dist = game_pos - player.position
	var target_velocity = dist * 3
	player.velocity = target_velocity
	player.light.color = display_color
	player.lightbreak.direction = Vector2.ZERO
	player.lightbreak.windup += player.get_physics_process_delta_time() * 2
	player.movement.is_crouching = true
	
	# get into the lightbreak faster if you release dir keys and hit the direction you want
	if player.control_vector.length() == 0:
		player.lightbreak.input_primed = true
	if player.control_vector.length() != 0 && player.lightbreak.input_primed:
		start_lightbreak(player, coords)
		return
	
	# at the light timeout, either go in the direction that is being pressed or drop out
	if player.lightbreak.windup >= 1:
		if player.control_vector.length() != 0:
			start_lightbreak(player, coords)
		else:
			player.end_lightbreak()
			player.lightbreak.src_tile = coords


func start_lightbreak(player: Node2D, coords: Vector2i) -> void:
	player.lightbreak.direction = Vector2(player.control_vector)
	player.lightbreak.src_tile = coords
	player.lightbreak.input_primed = false
	player.lightbreak.windup = 0.1
	player.lightbreak.type = lightbreak_type
