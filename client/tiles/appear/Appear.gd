extends Tile
class_name Appear

const APPEAR_EFFECT = preload("res://tiles/appear/AppearEffect.tscn")

var atlas_coords = Vector2i(9, 3)
var appear_effect

func init():
	matter_type = Tile.SOLID
	any_side.push_back(appear)

func appear(player: Node2D, tilemap: TileMap, coords: Vector2i):
	var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
	if atlas_coords == Vector2i(-1, -1):
		return
	
	if appear_effect != null:
		appear_effect.reinit()

	var tile_atlas = tilemap.tile_set.get_source(0).texture
	appear_effect = APPEAR_EFFECT.instantiate()
	appear_effect.position = coords * Settings.tile_size
	tilemap.add_child(appear_effect)
	appear_effect.init(tile_atlas, atlas_coords, tilemap, coords)

func activate_tilemap(tilemap: TileMap) -> void:
	var coord_list = tilemap.get_used_cells_by_id(0, 0, atlas_coords)
	for coords in coord_list:
		tilemap.get_cell_tile_data(0, coords).modulate.a = 0
