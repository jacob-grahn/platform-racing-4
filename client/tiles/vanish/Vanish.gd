extends Tile
class_name Vanish

const VANISH_EFFECT = preload("res://tiles/vanish/VanishEffect.tscn")

var vanish_effects = {} 

func init():
	matter_type = Tile.SOLID
	any_side.push_back(vanish)
	is_safe = false

func vanish(player: Node2D, tilemap: TileMap, coords: Vector2i):
	var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
	if atlas_coords == Vector2i(-1, -1):
		return
	if try_reinit(coords): # True: spawn new instance, False: animation is playing, attempt to despawn it early
		return

	tilemap.set_cell(0, coords, 0, atlas_coords, 1)
	var tile_atlas = tilemap.tile_set.get_source(0).texture
	var vanish_effect = VANISH_EFFECT.instantiate()
	vanish_effect.position = coords * Settings.tile_size
	tilemap.add_child(vanish_effect)
	vanish_effect.init(self, tile_atlas, atlas_coords, tilemap, coords)
	add_to_vanish_dict(coords, vanish_effect)

func try_reinit(coords: Vector2i) -> bool:
	var vanish_effect = vanish_effects.get(coords)
	if vanish_effect == null:
		return false
	vanish_effect._attempt_despawn_early()
	return true

func add_to_vanish_dict(coords: Vector2i, vanish_effect):
	vanish_effects[coords] = vanish_effect

func remove_from_vanish_dict(coords: Vector2i) -> void:
	vanish_effects.erase(coords)
