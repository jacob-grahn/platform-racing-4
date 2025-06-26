extends Tile
class_name Teleport

var positions = []
var recent_teleports = []
var color = "none"
var atlas_coords = Vector2i(0, 0)
var throttle_ms = 1000


func init():
	matter_type = Tile.SOLID
	any_side.push_back(teleport)
	is_safe = false


func activate_tilemap(tilemap: TileMap) -> void:
	var coord_list = tilemap.get_used_cells_by_id(0, 0, atlas_coords)
	for coords in coord_list:
		var position = {
			"layer_name": str(tilemap.get_parent().name),
			"coords": coords,
			"color": color,
			"tilemap": tilemap
		}
		positions.push_back(position)


func clear():
	positions = []
	recent_teleports = []


func teleport(player: Node2D, tilemap: TileMap, coords: Vector2i) -> void:
	var layer_name: String = str(tilemap.get_parent().name)
	var is_throttled = is_teleport_throttled(str(player.name), layer_name, coords)
	if is_throttled:
		return
		
	var source_position = {
		"layer_name": layer_name,
		"coords": coords,
		"color": color
	}
	var next_position = get_next_position(source_position)
	var layers = tilemap.get_node("../../")
	var layer = layers.get_node(next_position.layer_name)
	var source_block_position = Vector2(coords * Settings.tile_size + Settings.tile_size_half).rotated(tilemap.global_rotation)
	var next_block_position = Vector2(next_position.coords * Settings.tile_size + Settings.tile_size_half).rotated(next_position.tilemap.global_rotation)
	var dist = (player.position - source_block_position).rotated(next_position.tilemap.global_rotation)
	
	player.get_parent().remove_child(player)
	layer.get_node("Players").add_child(player)
	player.position = next_block_position + dist
	player.set_depth(layer.depth)
	throttle_teleport(str(player.name), next_position.layer_name, next_position.coords)
	
	Session.set_current_player_layer(next_position.layer_name)
	var minimap_container = tilemap.get_node("../../../UI/Minimaps")
	for child in minimap_container.get_children():
		child.visible = child.name == next_position.layer_name

func is_teleport_throttled(player_name: String, layer_name: String, coords: Vector2i) -> bool:
	# remove recent teleports older than throttle_ms
	var min_ms = Time.get_ticks_msec() - throttle_ms
	recent_teleports = recent_teleports.filter( func(record): return record.ms >= min_ms )
	
	# check if there is a match
	var is_throttled = false
	for record in recent_teleports:
		if record.player_name == player_name && record.layer_name == layer_name && record.coords == coords:
			is_throttled = true
			break
	
	# return the result
	return is_throttled
	

func throttle_teleport(player_name: String, layer_name: String, coords: Vector2i) -> void:
	recent_teleports.push_back({
		"player_name": player_name,
		"layer_name": layer_name,
		"coords": coords,
		"ms": Time.get_ticks_msec()
	})
	

func get_next_position(source_position: Dictionary) -> Dictionary:
	# find start index
	var i = 0
	while i < len(positions):
		var position = positions[i]
		if source_position.color == position.color && source_position.coords == position.coords && source_position.layer_name == position.layer_name:
			break
		i += 1
	
	# find next teleport block with the same color
	var j = 1
	var k
	while j < len(positions) + 1:
		k = (i + j) % len(positions)
		var position = positions[k]
		if source_position.color == position.color:
			break
		j += 1
	
	# return the next match
	return positions[k]
	
