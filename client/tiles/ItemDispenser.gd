extends Tile
class_name ItemDispenser

const RANDOM_BLOCK_ITEM = preload("res://items/RandomBlockItem.tscn")

var item_atlas_coords = Vector2i(0, 1)
var alternative_id = 10


func init():
	matter_type = Tile.SOLID
	bump.push_back(dispense_item)


func dispense_item(player: Node2D, tile_map: TileMap, coords: Vector2i):
	if tile_map.get_cell_alternative_tile(0, coords) == alternative_id:
		return
	
	# grant an item
	var item = RANDOM_BLOCK_ITEM.instantiate()
	player.set_item(item)
	
	# deactivate this tile
	deactivate(tile_map, coords)
	

func deactivate(tile_map: TileMap, coords: Vector2i):
	create_alternative_tile(tile_map.tile_set.get_source(0))
	tile_map.set_cell(0, coords, 0, item_atlas_coords, alternative_id)


func create_alternative_tile(source: TileSetAtlasSource) -> void:
	var result_id: int = source.create_alternative_tile(item_atlas_coords, alternative_id)
	
	# return if the alt tile already exists
	if result_id == -1:
		return
	
	var og_data: TileData =  source.get_tile_data(item_atlas_coords, 0)
	var data: TileData = source.get_tile_data(item_atlas_coords, alternative_id)
	data.modulate = Color(0.5, 0.5, 0.5, 1.0)
	data.add_collision_polygon(0)
	data.set_collision_polygon_points(0, 0, og_data.get_collision_polygon_points (0, 0))
