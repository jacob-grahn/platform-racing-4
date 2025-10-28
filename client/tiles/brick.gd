extends Tile
class_name Brick


func init():
	matter_type = Tile.SOLID
	bump.push_back(shatter)
	is_safe = false


func shatter(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	TileEffects.shatter(tile_map_layer, coords)
