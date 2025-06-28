extends Node
class_name TileEffects

const SHATTER_EFFECT = preload("res://tile_effects/shatter_effect/shatter_effect.tscn")
const BUMP_EFFECT = preload("res://tile_effects/bump_effect/bump_effect.tscn")


static func shatter(tile_map: TileMapLayer, coords: Vector2i):
	crumble(tile_map, coords)
	tile_map.set_cell(coords, -1)


static func crumble(tile_map: TileMapLayer, coords: Vector2i):
	var atlas_coords = tile_map.get_cell_atlas_coords(coords)
	if atlas_coords == Vector2i(-1, -1):
		return
	var tile_atlas = tile_map.tile_set.get_source(0).texture
	var shatter_effect = SHATTER_EFFECT.instantiate()
	shatter_effect.position = coords * Settings.tile_size
	shatter_effect.add_pieces(tile_atlas, atlas_coords)
	tile_map.add_child(shatter_effect)
	

static func bump(player: Node2D, tile_map: TileMapLayer, coords: Vector2i):
	var atlas_coords = tile_map.get_cell_atlas_coords(coords)
	if atlas_coords == Vector2i(-1, -1):
		return
	
	var effect_name = str(coords.x) + "-" + str(coords.y) + "-bump"
	if tile_map.has_node(effect_name):
		var effect = tile_map.get_node(effect_name)
		var animation_player = effect.get_node("AnimationPlayer") as AnimationPlayer
		animation_player.seek(0.1)
		return
	
	var alt_id: int = tile_map.get_cell_alternative_tile(coords)
	if alt_id == Tile.INVISIBLE_ALT_ID:
		return
	
	var bump_effect = BUMP_EFFECT.instantiate()
	bump_effect.name = effect_name
	tile_map.add_child(bump_effect)
	bump_effect.position = coords * Settings.tile_size + Settings.tile_size_half
	bump_effect.rotation = player.rotation - tile_map.global_rotation
	bump_effect.set_tile(tile_map, coords, -bump_effect.rotation)
	
	if alt_id == Tile.DEACTIVATED_ALT_ID:
		tile_map.set_cell(coords, 0, atlas_coords, Tile.INVISIBLE_DEACTIVATED_ALT_ID)
	else:
		tile_map.set_cell(coords, 0, atlas_coords, Tile.INVISIBLE_ALT_ID)
