extends Tile
class_name Brick


func init():
	matter_type = Tile.SOLID
	bump.push_back(shatter)


func shatter(player: Node2D, tilemap: TileMap, coords: Vector2i):
	TileEffects.shatter(tilemap, coords)
