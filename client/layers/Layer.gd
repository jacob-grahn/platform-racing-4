extends ParallaxBackground
class_name Layer

@onready var lines: Node2D = $Lines
@onready var tile_map = $TileMap
@onready var tile_map_mini: TileMap = get_node("../../UI/Minimap/TileMapMini")

const TILEATLAS = preload("res://tiles/tileatlas.png")
var depth = 10
var art_scale = 1.0

func init(tiles: Tiles) -> void:
	tile_map.tile_set = create_tile_set(tiles, true)
	tile_map_mini.tile_set = create_tile_set(tiles, false)
		
	set_depth(depth)

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
			if enable_collision:
				if tile.matter_type == Tile.SOLID:
					data.add_collision_polygon(0)
					data.set_collision_polygon_points(0, 0, polygon)
				else:
					data.add_collision_polygon(1)
					data.set_collision_polygon_points(1, 0, polygon)
		
		source.get_tile_data(atlas_coords, Tile.DEACTIVATED_ALT_ID).modulate = Color(0.5, 0.5, 0.5, 1.0)
		source.get_tile_data(atlas_coords, Tile.INVISIBLE_ALT_ID).modulate = Color(1.0, 1.0, 1.0, 0.0)
		source.get_tile_data(atlas_coords, Tile.INVISIBLE_DEACTIVATED_ALT_ID).modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	return tile_set

func set_depth(_depth: int) -> void:
	depth = _depth
	layer = depth
	
	var tile_set = tile_map.tile_set
	if tile_set:
		tile_set.set_physics_layer_collision_layer(0, Helpers.to_bitmask_32((depth * 2) - 1))
		tile_set.set_physics_layer_collision_mask(0, Helpers.to_bitmask_32((depth * 2) - 1))
		tile_set.set_physics_layer_collision_layer(1, Helpers.to_bitmask_32(depth * 2))
		tile_set.set_physics_layer_collision_mask(1, Helpers.to_bitmask_32(depth * 2))
	
	# pr2 has an art layer that scrolls at 25% scale
	# this hack treats depth 2 as 2.5 instead so imported levels look the same
	# probably there is some better solution, but will need more thinking
	var depth_compat = float(depth)
	if depth == 2:
		depth_compat = 2.5
	
	# aaaand pr2 has an art layer that scrolls at 200% scale
	# but our current setup maxes out at depth 16
	if depth == 16:
		depth_compat = 20.0
	
	# scale blocks up/down to match scale
	# currently this scales lines and art as well, which actually we don't want
	# todo: possibly only put tilemap and players in the viewport
	var base_scale = depth_compat / 10.0
	follow_viewport_scale = base_scale
	
	# scale lines to counteract the scaling on the viewport
	var inverse_scale = 1.0 / base_scale
	lines.scale = Vector2(inverse_scale * art_scale, inverse_scale * art_scale)
