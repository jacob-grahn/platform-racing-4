extends Tile
class_name Vanish

const VANISH_EFFECT = preload("res://tiles/vanish/VanishEffect.tscn")


func init():
	matter_type = Tile.SOLID
	any_side.push_back(vanish)


func vanish(player: Node2D, tilemap: TileMap, coords: Vector2i):
	var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
	if atlas_coords == Vector2i(-1, -1):
		return
	
	var tile_atlas = tilemap.tile_set.get_source(0).texture
	var vanish_effect = VANISH_EFFECT.instantiate()
	vanish_effect.position = coords * Settings.tile_size
	tilemap.add_child(vanish_effect)
	vanish_effect.init(tile_atlas, atlas_coords, tilemap, coords)

	tilemap.set_cell(-1, coords)
