extends Tile
class_name Vanish

const VANISH_EFFECT = preload("res://tiles/vanish/vanish_effect.tscn")

var vanish_effects = {} 

func init():
	matter_type = Tile.SOLID
	any_side.push_back(vanish)
	is_safe = false


func vanish(_player: Node2D, tilemap: TileMapLayer, coords: Vector2i):
	
	var atlas_coords = tilemap.get_cell_atlas_coords(coords)
	
	if atlas_coords == Vector2i(-1, -1):
		return
	
	if tilemap.get_cell_alternative_tile(coords) == 1:
		return
	
	if vanish_effects.has(coords):
		vanish_effects.get(coords).vanish_again()
		return
	
	tilemap.set_cell(coords, 0, atlas_coords, 1)
	
	var tile_atlas = tilemap.tile_set.get_source(0).texture
	var vanish_effect = VANISH_EFFECT.instantiate()
	
	tilemap.add_child(vanish_effect)
	
	vanish_effect.init(self, tile_atlas, atlas_coords, tilemap, coords)
	vanish_effect.position = coords * Settings.tile_size
	
	add_to_vanish_dict(coords, vanish_effect)


func add_to_vanish_dict(coords: Vector2i, vanish_effect: VanishEffect) -> void:
	vanish_effects[coords] = vanish_effect

func remove_from_vanish_dict(coords: Vector2i) -> void:
	vanish_effects.erase(coords)
