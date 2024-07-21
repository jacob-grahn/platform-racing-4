extends ParallaxBackground

@onready var tile_map = $TileMap
const TILEATLAS = preload("res://tiles/tileatlas.png")

func init(tiles: Tiles) -> void:
	var source: TileSetAtlasSource = TileSetAtlasSource.new()
	source.texture = TILEATLAS
	source.texture_region_size = Settings.tile_size
	
	for tile_id in tiles.map:
		var tile: Tile = tiles.map[tile_id]
		var atlas_coords: Vector2i = Helpers.to_atlas_coords(int(tile_id))
		source.create_tile(atlas_coords)
		var data: TileData = source.get_tile_data(atlas_coords, 0)
		var polygon: PackedVector2Array = PackedVector2Array([Vector2(0, 0), Vector2(Settings.tile_size.x, 0), Vector2(Settings.tile_size.x, Settings.tile_size.y), Vector2(0, Settings.tile_size.y)])
		if tile.matter_type == Tile.SOLID:
			data.add_collision_polygon(0)
			data.set_collision_polygon_points(0, 0,  polygon)
		else:
			data.add_collision_polygon(1)
			data.set_collision_polygon_points(0, 1, polygon)
	
	var tile_set = TileSet.new()
	tile_set.tile_size = Settings.tile_size
	tile_set.add_physics_layer()
	tile_set.add_physics_layer()
	tile_set.set_physics_layer_collision_layer(0, to_bitmask_32(layer))
	tile_set.set_physics_layer_collision_layer(0, to_bitmask_32(layer + 1))
	tile_set.add_source(source)
	
	# 
	tile_map.tile_set = tile_set



func to_bitmask_32(num: int) -> int:
	if num < 1 or num > 32:
		return 0 # Return 0 for out of range numbers
	return 1 << (num - 1)
