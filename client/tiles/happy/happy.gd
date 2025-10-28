extends Tile
class_name Happy

var default_increment: int = 5
var increment: int = 5

func init():
	matter_type = Tile.ACTIVE
	bump.push_back(happy)
	is_safe = true


func happy(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	if is_active(tile_map_layer, coords):
		player.stats.inc_all(increment)
		Jukebox.play_sound("bumphappy")
		deactivate(tile_map_layer, coords)
