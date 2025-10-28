class_name TileInteractionController
## Manages character interactions with tiles in the game world.
## Handles collision detection, tile effects, and character depth management.

const OUT_OF_BOUNDS_BLOCK_COUNT = 15

var game: Node2D
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

func get_tile_covering_high_area(character: Character) -> Dictionary:
	var tiles: Array = get_tiles_overlapping_area(high_area)
	
	if tiles.size() == 0:
		push_error("TileInteractionController::bump_tile_covering_high_area - No tile covering high area")
		return {}
	
	var tile = tiles[0]
	return tile


func should_crouch(character: Character) -> bool:
	if !character.is_on_floor():
		return false
	var tiles_overlapping: Array = get_tiles_overlapping_area(high_area)
	for tile_data in tiles_overlapping:
		if _tiles.is_solid(tile_data.block_id):
			return true
	return false


func interact_with_incoporeal_tiles(character: Character):
	character.movement.swimming = false
	var tiles_overlapping: Array = get_tiles_overlapping_area(low_area)
	
	if tiles_overlapping.size() == 0:
		return
	
	var overlapping_tile = tiles_overlapping[0]
	if _tiles.is_liquid(overlapping_tile.block_id):
		character.movement.swimming = true
	_tiles.on("area", overlapping_tile.block_id, character, overlapping_tile.tile_map_layer, overlapping_tile.coords)


func interact_with_solid_tiles(character: Character, lightning: LightbreakController) -> bool:
	var collision: KinematicCollision2D = character.get_last_slide_collision()
	last_collision = collision
	if !collision:
		return false
		
	var tile_map_layer = collision.get_collider()
	if not (tile_map_layer is TileMapLayer):
		return false

	var normal = collision.get_normal().rotated(-character.rotation)
	var rid = collision.get_collider_rid()
	var coords = tile_map_layer.get_coords_for_body_rid(rid)
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(coords)
	var tile_type = CoordinateUtils.to_block_id(atlas_coords)
	var bumped_tile = {"tile_map_layer": tile_map_layer, "coords": coords, "atlas_coords": atlas_coords, "block_id": tile_type}
	
	character.movement.last_collision_normal = normal
	
	if abs(normal.x) > abs(normal.y):
		if normal.x > 0:
			_tiles.on("left", tile_type, character, tile_map_layer, coords)
			_tiles.on("any_side", tile_type, character, tile_map_layer, coords)
		else:
			_tiles.on("right", tile_type, character, tile_map_layer, coords)
			_tiles.on("any_side", tile_type, character, tile_map_layer, coords)
	else:
		if normal.y > 0:
			character.movement.attempting_bump = true
			character.movement.jumped = false
			character.movement.jump_timer = 0
			character.velocity.rotated(character.rotation).y = 0
			if bumped_tile != character.movement.last_bumped_block and tile_type != 7:
				character.movement.last_bumped_block = bumped_tile
				_tiles.on("bottom", tile_type, character, tile_map_layer, coords)
				_tiles.on("any_side", tile_type, character, tile_map_layer, coords)
				_tiles.on("bump", tile_type, character, tile_map_layer, coords)
				Jukebox.play_sound("bump")
		else:
			_tiles.on("top", tile_type, character, tile_map_layer, coords)
			_tiles.on("any_side", tile_type, character, tile_map_layer, coords)
			_tiles.on("stand", tile_type, character, tile_map_layer, coords)
			if _tiles.is_safe(tile_type) and tile_map_layer.name.contains("gear") == false:
				var centre_safe_block = Vector2(
						coords.x * Settings.tile_size_half.x * 2 + Settings.tile_size_half.x,
						coords.y * Settings.tile_size_half.y * 2 + Settings.tile_size_half.y
				).rotated(tile_map_layer.global_rotation)
				last_safe_position = centre_safe_block - (Vector2(
						0, 
						(1 * Settings.tile_size.y) - 22
				)).rotated(tile_map_layer.global_rotation + character.rotation)
				if Game.game:
					var level_manager = Game.game.get_node("LevelManager")
					if level_manager:
						last_safe_layer = level_manager.layers.block_layers.get_node(str(str(tile_map_layer.get_parent().name)))
	
	# Blow up tiles when sun lightbreaking
	if lightning.direction.length() > 0 and lightning.fire_power > 0:
		TileEffects.shatter(tile_map_layer, coords, 10)
		lightning.fire_power -= 1
		return false
	else:
		return true


func check_out_of_bounds(character: Character) -> void:
	if not Game.game:
		return
	var current_layer = Game.game.get_current_player_layer()
	if not current_layer:
		return
	var map_used_rect = Game.game.get_used_rect(current_layer)
	
	var min_x = map_used_rect.position.x - OUT_OF_BOUNDS_BLOCK_COUNT
	var max_x = map_used_rect.position.x + map_used_rect.size.x + OUT_OF_BOUNDS_BLOCK_COUNT
	var min_y = map_used_rect.position.y - OUT_OF_BOUNDS_BLOCK_COUNT
	var max_y = map_used_rect.position.y + map_used_rect.size.y + OUT_OF_BOUNDS_BLOCK_COUNT
	
	var player_x_normalised = character.position.x / Settings.tile_size.x
	var player_y_normalised = character.position.y / Settings.tile_size.y
		
	if player_x_normalised < min_x or player_x_normalised > max_x or \
	   player_y_normalised > max_y:
		character.position.x = last_safe_position.x
		character.position.y = last_safe_position.y
		character.velocity = Vector2(0, 0)


func get_tiles_overlapping_area(area: Area2D) -> Array:
	var tiles = []
	var bodies: Array = area.get_overlapping_bodies()
	for tile_map_layer in bodies:
		if !(tile_map_layer is TileMapLayer):
			continue
		var coords = tile_map_layer.local_to_map(tile_map_layer.to_local(area.to_global(Vector2.ZERO)))
		var atlas_coords = tile_map_layer.get_cell_atlas_coords(coords)
		var block_id = CoordinateUtils.to_block_id(atlas_coords)
		if block_id != 0:
			tiles.push_back({
				"tile_map_layer": tile_map_layer,
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
