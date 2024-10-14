extends ParallaxBackground
class_name Layer

@onready var lines: Node2D = $Lines
@onready var tile_map = $TileMap
const TILEATLAS = preload("res://tiles/tileatlas.png")
var depth = 10


func init(tiles: Tiles) -> void:
	var source: TileSetAtlasSource = TileSetAtlasSource.new()
	source.texture = TILEATLAS
	source.texture_region_size = Settings.tile_size
	
	var tile_set = TileSet.new()
	tile_set.tile_size = Settings.tile_size
	tile_set.add_source(source)
	tile_set.add_physics_layer()
	tile_set.add_physics_layer()
	
	for tile_id in tiles.map:
		var tile: Tile = tiles.map[tile_id]
		var atlas_coords: Vector2i = Helpers.to_atlas_coords(int(tile_id))
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
			if tile.matter_type == Tile.SOLID:
				data.add_collision_polygon(0)
				data.set_collision_polygon_points(0, 0, polygon)
			else:
				data.add_collision_polygon(1)
				data.set_collision_polygon_points(1, 0, polygon)
		
		source.get_tile_data(atlas_coords, Tile.DEACTIVATED_ALT_ID).modulate = Color(0.5, 0.5, 0.5, 1.0)
		source.get_tile_data(atlas_coords, Tile.INVISIBLE_ALT_ID).modulate = Color(1.0, 1.0, 1.0, 0.0)
		source.get_tile_data(atlas_coords, Tile.INVISIBLE_DEACTIVATED_ALT_ID).modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	#
	tile_map.tile_set = tile_set
	set_depth(depth)


func set_depth(_depth: int) -> void:
	depth = _depth
	layer = depth
	
	var tile_set = tile_map.tile_set
	if tile_set:
		tile_set.set_physics_layer_collision_layer(0, Helpers.to_bitmask_32((depth * 2) - 1))
		tile_set.set_physics_layer_collision_mask(0, Helpers.to_bitmask_32((depth * 2) - 1))
		tile_set.set_physics_layer_collision_layer(1, Helpers.to_bitmask_32(depth * 2))
		tile_set.set_physics_layer_collision_mask(1, Helpers.to_bitmask_32(depth * 2))
	
	var depth_compat = depth
	if depth == 2:
		depth_compat = 2.5
	var base_scale = depth_compat / 10.0
	var inverse_scale = 1.0 / base_scale
	lines.scale = Vector2(inverse_scale, inverse_scale)
	follow_viewport_scale = depth_compat / 10
