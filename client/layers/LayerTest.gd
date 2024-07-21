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
	tile_map.set_cell(0, coords, source_id, atlas_coords, alternative_tile)
