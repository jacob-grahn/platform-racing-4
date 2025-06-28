extends Tile
class_name Push

var push_atlas_coords = Vector2i(3, 2)


func init():
	matter_type = Tile.SOLID
	any_side.push_back(push)
	is_safe = false


func push(player: Node2D, tilemap: TileMapLayer, coords: Vector2i):
	var tile_position = Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half).rotated(tilemap.rotation)
	var direction = tile_position - player.position
	var atlas_coords = tilemap.get_cell_atlas_coords(coords)
	
	# force direction into 1 move
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			direction.x = 1
			direction.y = 0
		else:
			direction.x = -1
			direction.y = 0
	else:
		if direction.y > 0:
			direction.x = 0
			direction.y = 1
		else:
			direction.x = 0
			direction.y = -1
	
	# move over other move blocks, creates the illusion that they all move over one
	var target_coords = coords + Vector2i(direction)
	while true:
		var existing_atlas_coords = tilemap.get_cell_atlas_coords(target_coords)
		if existing_atlas_coords == push_atlas_coords:
			target_coords = target_coords + Vector2i(direction)
		else:
			break
	
	# prevent moving through other blocks
	var existing_atlas_coords = tilemap.get_cell_atlas_coords(target_coords)
	if existing_atlas_coords != Vector2i(-1, -1):
		return
	
	# move!
	tilemap.set_cell(coords, -1)
	tilemap.set_cell(target_coords, 0, atlas_coords)
