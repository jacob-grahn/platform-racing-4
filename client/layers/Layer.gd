extends ParallaxBackground

@onready var tile_map = $TileMap
const TILEATLAS = preload("res://tiles/tileatlas.png")

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
		source.create_tile(atlas_coords)
		var data: TileData = source.get_tile_data(atlas_coords, 0)
		var polygon: PackedVector2Array = PackedVector2Array([
			Vector2(-Settings.tile_size_half.x, -Settings.tile_size_half.y),
			Vector2(Settings.tile_size_half.x, -Settings.tile_size_half.y),
			Vector2(Settings.tile_size_half.x, Settings.tile_size_half.y), 
			Vector2(-Settings.tile_size_half.x, Settings.tile_size_half.y)
		])
		
		if tile.matter_type == Tile.SOLID:
			data.add_collision_polygon(0)
			data.set_collision_polygon_points(0, 0, polygon)
		else:
			data.add_collision_polygon(1)
			data.set_collision_polygon_points(1, 0, polygon)
	
	#
	tile_map.tile_set = tile_set
	set_depth(round(follow_viewport_scale * 10))
	


func set_depth(depth: int) -> void:
	var tile_set = tile_map.tile_set
	tile_set.set_physics_layer_collision_layer(0, Helpers.to_bitmask_32(depth * 2))
	tile_set.set_physics_layer_collision_mask(0, Helpers.to_bitmask_32(depth * 2))
	tile_set.set_physics_layer_collision_layer(1, Helpers.to_bitmask_32((depth * 2) + 1))
	tile_set.set_physics_layer_collision_mask(1, Helpers.to_bitmask_32((depth * 2) + 1))
