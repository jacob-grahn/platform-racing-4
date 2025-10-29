extends Tile
class_name Ice


func init():
	matter_type = Tile.SOLID
	any_side.push_back(freeze)
	is_safe = true


func freeze(player: Node2D, tilemap: TileMap, coords: Vector2i):
	player.freeze()
