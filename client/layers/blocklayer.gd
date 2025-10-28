extends ParallaxBackground
class_name BlockLayer

@onready var tile_map_layer = $TileMapLayer

const TILEATLAS = preload("res://tiles/tileatlas.png")

var z_axis = 10
var depth = z_axis # cannot be set by layer panel, mostly here for compatibility with existing code
var tile_map_rotation = 0


func init(tiles: Tiles) -> void:
	tile_map_layer.tile_set = create_tile_set(tiles, true)
	tile_map_layer.tile_set.uv_clipping = true
	set_z_axis(z_axis)
	set_block_layer_rotation(tile_map_rotation)

func create_tile_set(tiles: Tiles, enable_collision: bool) -> TileSet:
	var source: TileSetAtlasSource = TileSetAtlasSource.new()
	source.texture = TILEATLAS
	source.texture_region_size = Settings.tile_size
	
	var tile_set = TileSet.new()
	tile_set.tile_size = Settings.tile_size
	tile_set.add_source(source)
	
	if enable_collision:
		tile_set.add_physics_layer()
		tile_set.add_physics_layer()
	
	for tile_id in tiles.map:
		var tile: Tile = tiles.map[tile_id]
		var atlas_coords: Vector2i = CoordinateUtils.to_atlas_coords(int(tile_id))
		var polygon: PackedVector2Array = PackedVector2Array([
			Vector2(-Settings.tile_size_half.x, -Settings.tile_size_half.y),
			Vector2(Settings.tile_size_half.x, -Settings.tile_size_half.y),
			Vector2(Settings.tile_size_half.x, Settings.tile_size_half.y), 
			Vector2(-Settings.tile_size_half.x, Settings.tile_size_half.y)
		])
		
		source.create_tile(atlas_coords)
		source.create_alternative_tile(atlas_coords, Tile.DEACTIVATED_ALT_ID)
		source.create_alternative_tile(atlas_coords, Tile.INVISIBLE_ALT_ID)
		source.create_alternative_tile(atlas_coords, Tile.INVISIBLE_DEACTIVATED_ALT_ID)
		
		for data in [
			source.get_tile_data(atlas_coords, 0),
			source.get_tile_data(atlas_coords, Tile.DEACTIVATED_ALT_ID),
			source.get_tile_data(atlas_coords, Tile.INVISIBLE_ALT_ID),
			source.get_tile_data(atlas_coords, Tile.INVISIBLE_DEACTIVATED_ALT_ID)
		]:
			if enable_collision:
				if tile.matter_type == Tile.ACTIVE:
					data.add_collision_polygon(0)
					data.set_collision_polygon_points(0, 0, polygon)
				else:
					data.add_collision_polygon(1)
					data.set_collision_polygon_points(1, 0, polygon)
		
		source.get_tile_data(atlas_coords, Tile.DEACTIVATED_ALT_ID).modulate = Color(0.5, 0.5, 0.5, 1.0)
		source.get_tile_data(atlas_coords, Tile.INVISIBLE_ALT_ID).modulate = Color(1.0, 1.0, 1.0, 0.0)
		source.get_tile_data(atlas_coords, Tile.INVISIBLE_DEACTIVATED_ALT_ID).modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	return tile_set


func set_z_axis(p_z_axis: int) -> void:
	z_axis = p_z_axis
	depth = z_axis
	layer = z_axis
	
	var tile_set = tile_map_layer.tile_set
	if tile_set:
		tile_set.set_physics_layer_collision_layer(0, Helpers.to_bitmask_32((z_axis * 2) - 1))
		tile_set.set_physics_layer_collision_mask(0, Helpers.to_bitmask_32((z_axis * 2) - 1))
		tile_set.set_physics_layer_collision_layer(1, Helpers.to_bitmask_32(z_axis * 2))
		tile_set.set_physics_layer_collision_mask(1, Helpers.to_bitmask_32(z_axis * 2))
	
	var z_axis_compat = float(z_axis)
	# scale blocks up/down to match scale
	# currently this scales lines and art as well, which actually we don't want
	# todo: possibly only put tile_map_layer and players in the viewport
	var base_scale = z_axis_compat / 10.0
	follow_viewport_scale = base_scale


func set_block_layer_rotation(p_rotation: float) -> void:
	tile_map_rotation = p_rotation
	tile_map_layer.rotation_degrees = tile_map_rotation
