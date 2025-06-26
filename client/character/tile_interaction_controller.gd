class_name TileInteractionController
## Manages character interactions with tiles in the game world.
## Handles collision detection, tile effects, and character depth management.

const OUT_OF_BOUNDS_BLOCK_COUNT = 10

var _tiles: Tiles
var low_area: Area2D
var high_area: Area2D
var last_safe_position: Vector2 = Vector2(0, 0)
var last_safe_layer: Node
var last_collision: KinematicCollision2D


func _init(tiles_node: Tiles, low_area_node: Area2D, high_area_node: Area2D):
	_tiles = tiles_node
	low_area = low_area_node
	high_area = high_area_node
	last_safe_position = Vector2(0, 0)


func bump_tile_covering_high_area(character: Character) -> void:
	var tiles: Array = get_tiles_overlapping_area(high_area)
	
	if tiles.size() == 0:
		push_error("TileInteractionController::bump_tile_covering_high_area - No tile covering high area")
		return
	
	var tile = tiles[0]
	var tile_type = CoordinateUtils.to_block_id(tile.atlas_coords)
	
	_tiles.on("bottom", tile_type, character, tile.tile_map, tile.coords)
	_tiles.on("any_side", tile_type, character, tile.tile_map, tile.coords)
	_tiles.on("bump", tile_type, character, tile.tile_map, tile.coords)


func should_crouch(character: Character) -> bool:
	if character.movement.is_crouching and !character.is_on_floor():
		return false
	var tiles_overlapping: Array = get_tiles_overlapping_area(high_area)
	for tile_data in tiles_overlapping:
		if _tiles.is_solid(tile_data.block_id):
			return true
	return false


func interact_with_incoporeal_tiles(character: Character):
	character.movement.swimming = false
	var tiles_overlapping: Array = get_tiles_overlapping_area(low_area)
	for tile in tiles_overlapping:
		if _tiles.is_liquid(tile.block_id):
			character.movement.swimming = true
		_tiles.on("area", tile.block_id, character, tile.tile_map, tile.coords)


func interact_with_solid_tiles(character: Character, lightning: LightbreakController) -> bool:
	var collision: KinematicCollision2D = character.get_last_slide_collision()
	last_collision = collision
	if !collision:
		return false
		
	var tilemap = collision.get_collider()
	if tilemap.get_class() != "TileMap":
		return false

	var normal = collision.get_normal().rotated(-character.rotation)
	var rid = collision.get_collider_rid()
	var coords = tilemap.get_coords_for_body_rid(rid)
	var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
	var tile_type = CoordinateUtils.to_block_id(atlas_coords)
	
	character.movement.last_collision_normal = normal
	
	if abs(normal.x) > abs(normal.y):
		if normal.x > 0:
			_tiles.on("left", tile_type, character, tilemap, coords)
			_tiles.on("any_side", tile_type, character, tilemap, coords)
		else:
			_tiles.on("right", tile_type, character, tilemap, coords)
			_tiles.on("any_side", tile_type, character, tilemap, coords)
	else:
		if normal.y > 0:
			_tiles.on("bottom", tile_type, character, tilemap, coords)
			_tiles.on("any_side", tile_type, character, tilemap, coords)
			_tiles.on("bump", tile_type, character, tilemap, coords)
		else:
			_tiles.on("top", tile_type, character, tilemap, coords)
			_tiles.on("any_side", tile_type, character, tilemap, coords)
			_tiles.on("stand", tile_type, character, tilemap, coords)
			if _tiles.is_safe(tile_type) and tilemap.name.contains("gear") == false:
				var centre_safe_block = Vector2(
						coords.x * Settings.tile_size_half.x * 2 + Settings.tile_size_half.x,
						coords.y * Settings.tile_size_half.y * 2 + Settings.tile_size_half.y
				).rotated(tilemap.global_rotation)
				last_safe_position = centre_safe_block - (Vector2(
						0, 
						(1 * Settings.tile_size.y) - 22
				)).rotated(tilemap.global_rotation + character.rotation)
				var layers = Global.layers
				if layers:
					last_safe_layer = layers.get_node(str(str(tilemap.get_parent().name)))
	
	# Blow up tiles when sun lightbreaking
	if lightning.direction.length() > 0 and lightning.fire_power > 0:
		TileEffects.shatter(tilemap, coords)
		lightning.fire_power -= 1
		return false
	else:
		return true


func check_out_of_bounds(character: Character) -> void:
	var map_used_rect = Session.get_used_rect()
	
	var min_x = map_used_rect.position.x - OUT_OF_BOUNDS_BLOCK_COUNT
	var max_x = map_used_rect.position.x + map_used_rect.size.x + OUT_OF_BOUNDS_BLOCK_COUNT
	var min_y = map_used_rect.position.y - OUT_OF_BOUNDS_BLOCK_COUNT
	var max_y = map_used_rect.position.y + map_used_rect.size.y + OUT_OF_BOUNDS_BLOCK_COUNT
	
	var player_x_normalised = character.position.x / Settings.tile_size.x
	var player_y_normalised = character.position.y / Settings.tile_size.y
		
	if player_x_normalised < min_x or player_x_normalised > max_x or \
	   player_y_normalised < min_y or player_y_normalised > max_y:
		character.position.x = last_safe_position.x
		character.position.y = last_safe_position.y
		character.velocity = Vector2(0, 0)


func get_tiles_overlapping_area(area: Area2D) -> Array:
	var tiles = []
	var bodies: Array = area.get_overlapping_bodies()
	for tile_map in bodies:
		if !(tile_map is TileMap):
			continue
		var coords = tile_map.local_to_map(tile_map.to_local(area.to_global(Vector2.ZERO)))
		var atlas_coords = tile_map.get_cell_atlas_coords(0, coords)
		var block_id = CoordinateUtils.to_block_id(atlas_coords)
		if block_id != 0:
			tiles.push_back({
				"tile_map": tile_map,
				"coords": coords,
				"atlas_coords": atlas_coords,
				"block_id": block_id
			})
	return tiles
	

func is_in_solid(character: Character) -> bool:
	var tiles_overlapping: Array = get_tiles_overlapping_area(low_area)
	for tile in tiles_overlapping:
		if _tiles.is_solid(tile.block_id):
			return true
	return false


func set_depth(character: Character, depth: int) -> void:
	var solid_layer = Helpers.to_bitmask_32((depth * 2) - 1)
	var vapor_layer = Helpers.to_bitmask_32(depth * 2)
	character.collision_layer = solid_layer
	character.collision_mask = solid_layer
	low_area.collision_layer = vapor_layer
	low_area.collision_mask = solid_layer | vapor_layer
	high_area.collision_mask = solid_layer
