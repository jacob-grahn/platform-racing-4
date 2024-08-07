extends Tile
class_name Appear

const APPEAR_EFFECT = preload("res://tiles/appear/AppearEffect.tscn")

var atlas_coords = Vector2i(9, 3)
var appear_effects = {} 

func init():
	matter_type = Tile.SOLID
	any_side.push_back(appear)

func appear(player: Node2D, tilemap: TileMap, coords: Vector2i):
	var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
	if atlas_coords == Vector2i(-1, -1):
		return

	if try_reinit(coords):
		return

	var tile_atlas = tilemap.tile_set.get_source(0).texture
	var appear_effect = APPEAR_EFFECT.instantiate()
	appear_effect.position = coords * Settings.tile_size
	tilemap.add_child(appear_effect)
	appear_effect.init(self, tile_atlas, atlas_coords, tilemap, coords)
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

func activate_tilemap(tilemap: TileMap) -> void:
	var coord_list = tilemap.get_used_cells_by_id(0, 0, atlas_coords)
	for coords in coord_list:
		tilemap.get_cell_tile_data(0, coords).modulate.a = 0
