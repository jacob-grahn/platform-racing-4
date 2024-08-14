extends Tile
class_name Mine

const EXPLODE_EFFECT = preload("res://tiles/mine/ExplodeEffect.tscn")


func init():
	matter_type = Tile.SOLID
	any_side.push_back(explode)
	is_safe = false


func explode(player: Node2D, tilemap: TileMap, coords: Vector2i):
	if player.shield.is_active():
		return
	TileEffects.shatter(tilemap, coords)
	var direction = player.position - (Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half)).rotated(tilemap.rotation)
	var push_velocity = direction.normalized() * 5000
	player.velocity += push_velocity
	var effect = EXPLODE_EFFECT.instantiate()
	effect.position = Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half)
	tilemap.add_child(effect)
	
