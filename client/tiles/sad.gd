extends Tile
class_name Sad


func init():
	matter_type = Tile.SOLID
	bump.push_back(sad)
	is_safe = true


func sad(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	if is_active(tile_map_layer, coords):
		player.stats.inc_all(-5)
		deactivate(tile_map_layer, coords)
