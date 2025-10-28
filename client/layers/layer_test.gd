extends Node2D

var tiles: Tiles = Tiles.new()
@onready var layer = $Layer


func _ready():
	tiles.init_defaults()
	layer.init(tiles)
	var tile_map_layer: TileMapLayer = layer.get_node("TileMapLayer")
	var coords = Vector2i(1, 1)
	var source_id = 0
	var atlas_coords = CoordinateUtils.to_atlas_coords(4)
	var alternative_tile = 0
	tile_map_layer.set_cell(Vector2i(1, 10), source_id, atlas_coords, alternative_tile)
	tile_map_layer.set_cell(Vector2i(2, 10), source_id, atlas_coords, alternative_tile)
	tile_map_layer.set_cell(Vector2i(3, 10), source_id, atlas_coords, alternative_tile)
	tile_map_layer.set_cell(Vector2i(4, 10), source_id, atlas_coords, alternative_tile)
	tile_map_layer.collision_visibility_mode = TileMapLayer.DEBUG_VISIBILITY_MODE_FORCE_SHOW
	
	var tile_data_1 = tile_map_layer.tile_set.get_source(0).get_tile_data(Vector2i(0, 0), 0)
