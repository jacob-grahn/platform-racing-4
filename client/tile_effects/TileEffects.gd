extends Node
class_name TileEffects

const SHATTER_EFFECT = preload("res://tile_effects/shatter_effect/ShatterEffect.tscn")
const BUMP_EFFECT = preload("res://tile_effects/bump_effect/BumpEffect.tscn")


static func shatter(tilemap: TileMap, coords: Vector2i):
	var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
	if atlas_coords == Vector2i(-1, -1):
		return
	var tile_atlas = tilemap.tile_set.get_source(0).texture
	var shatter_effect = SHATTER_EFFECT.instantiate()
	shatter_effect.position = coords * Settings.tile_size
	shatter_effect.add_pieces(tile_atlas, atlas_coords)
	tilemap.get_parent().add_child(shatter_effect)
	tilemap.set_cell(-1, coords)


static func bump(player: Node2D, tilemap: TileMap, coords: Vector2i):
	var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
	if atlas_coords == Vector2i(-1, -1):
		return
		
	var atlas = tilemap.tile_set.get_source(0).texture
	var node = tilemap.get_parent()
	var effect_name = str(coords.x) + "-" + str(coords.y) + "-bump"
	var existing_bump_effect = node.get_node(effect_name)
	if existing_bump_effect:
		existing_bump_effect.get_node("AnimationPlayer").seek(0.1)
		return 
		
	var bump_effect = BUMP_EFFECT.instantiate()
	bump_effect.name = effect_name
	tilemap.add_child(bump_effect)
	bump_effect.position = coords * Settings.tile_size + Settings.tile_size_half
	bump_effect.rotation = player.rotation - tilemap.global_rotation
	bump_effect.set_tile(atlas, atlas_coords, -bump_effect.rotation)
