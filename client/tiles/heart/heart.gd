extends Tile
class_name Heart


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(shield)
	is_safe = true


func shield(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	player.invincibility.activate()
