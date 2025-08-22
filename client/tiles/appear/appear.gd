extends Tile
class_name Appear

const APPEAR_EFFECT = preload("res://tiles/appear/appear_effect.tscn")

var atlas_coords = Vector2i(9, 33)
var appear_effects = {} 

func init():
	matter_type = Tile.ACTIVE
	any_side.push_back(appear)

func appear(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(coords)
	if atlas_coords == Vector2i(-1, -1):
		return

	if try_reinit(coords):
		return

	var tile_atlas = tile_map_layer.tile_set.get_source(0).texture
	var appear_effect = APPEAR_EFFECT.instantiate()
	appear_effect.position = coords * Settings.tile_size
	tile_map_layer.add_child(appear_effect)
	appear_effect.init(self, tile_atlas, atlas_coords, tile_map_layer, coords)
	add_to_appear_dict(coords, appear_effect)
	
func try_reinit(coords: Vector2i) -> bool:
	var appear_effect = appear_effects.get(coords)
	if appear_effect != null:
		appear_effect.reinit()
		return true
	return false

func add_to_appear_dict(coords: Vector2i, appear_effect):
	appear_effects[coords] = appear_effect

func remove_from_appear_dict(coords: Vector2i) -> void:
	appear_effects.erase(coords)
	print("remove ", coords)

func activate_tile_map_layer(tile_map_layer: TileMapLayer) -> void:
	var coord_list = tile_map_layer.get_used_cells_by_id(0, atlas_coords)
	for coords in coord_list:
		tile_map_layer.get_cell_tile_data(coords).modulate.a = 0
