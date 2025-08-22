extends Tile
class_name Mine

const EXPLODE_EFFECT = preload("res://tiles/mine/explode_effect.tscn")


func init():
	matter_type = Tile.ACTIVE
	any_side.push_back(explode)
	is_safe = false


func explode(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	if player.invincibility.is_active():
		return
	TileEffects.shatter(tile_map_layer, coords, 10)
	var direction = player.position - (Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half)).rotated(tile_map_layer.rotation)
	var push_velocity = direction.normalized() * 5000
	player.velocity += push_velocity
	var effect = EXPLODE_EFFECT.instantiate()
	effect.position = Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half)
	tile_map_layer.add_child(effect)
	player.hitstun(2.5)
