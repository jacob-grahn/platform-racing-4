extends Tile
class_name Hurt


func init():
	matter_type = Tile.ACTIVE
	any_side.push_back(hurt)
	is_safe = false


func hurt(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	if player.invincibility.is_active():
		return
	if !player.movement.hurt:
		var direction = player.position - (Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half)).rotated(tile_map_layer.rotation)
		var push_velocity = direction.normalized() * 1000
		player.velocity += push_velocity
		player.hitstun(2.5)
