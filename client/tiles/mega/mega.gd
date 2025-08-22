extends Tile
class_name Mega


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(grow)
	is_safe = true


func grow(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	if player.movement.size.x < 1:
		player.movement.size.x = 1
	else:
		player.movement.size.x = 2
	if player.movement.size.y < 1:
		player.movement.size.y = 1
	else:
		player.movement.size.y = 2
