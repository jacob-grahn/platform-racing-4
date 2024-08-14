extends Tile
class_name Heart


func init():
	matter_type = Tile.SOLID
	bump.push_back(shield)
	is_safe = true


func shield(player: Node2D, tile_map: TileMap, coords: Vector2i):
	player.shield.activate()
