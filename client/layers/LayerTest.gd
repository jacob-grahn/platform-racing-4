extends Node2D

var tiles: Tiles = Tiles.new()
@onready var layer = $Layer


func _ready():
	tiles.init_defaults()
	layer.init(tiles)
	var tile_map: TileMap = layer.get_node("TileMap")
	var coords = Vector2i(1, 1)
	var source_id = 0
	var atlas_coords = Helpers.to_atlas_coords(4)
	var alternative_tile = 0
	tile_map.set_cell(0, Vector2i(1, 10), source_id, atlas_coords, alternative_tile)
	tile_map.set_cell(0, Vector2i(2, 10), source_id, atlas_coords, alternative_tile)
	tile_map.set_cell(0, Vector2i(3, 10), source_id, atlas_coords, alternative_tile)
	tile_map.set_cell(0, Vector2i(4, 10), source_id, atlas_coords, alternative_tile)
	tile_map.collision_visibility_mode = TileMap.VISIBILITY_MODE_FORCE_SHOW
	
	var tile_data_1 = tile_map.tile_set.get_source(0).get_tile_data(Vector2i(0, 0), 0)
	var tile_data_2 = $TileMap.tile_set.get_source(0).get_tile_data(Vector2i(0, 0), 0)
