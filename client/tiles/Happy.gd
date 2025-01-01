extends Tile
class_name Happy


func init():
	matter_type = Tile.SOLID
	bump.push_back(happy)
	is_safe = true


func happy(player: Node2D, tile_map: TileMap, coords: Vector2i):
	if is_active(tile_map, coords):
		player.stats.inc_all(5)
		deactivate(tile_map, coords)
