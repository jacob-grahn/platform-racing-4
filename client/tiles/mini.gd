extends Tile
class_name Mini


func init():
	matter_type = Tile.SOLID
	bump.push_back(shrink)
	is_safe = true


func shrink(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	if player.movement.size.x > 1:
		player.movement.size.x = 1
	else:
		player.movement.size.x = 0.5
	if player.movement.size.y > 1:
		player.movement.size.y = 1
	else:
		player.movement.size.y = 0.5
