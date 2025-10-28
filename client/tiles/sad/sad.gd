extends Tile
class_name Sad

var default_decrement: int = -5
var decrement: int = -5

func init():
	matter_type = Tile.ACTIVE
	bump.push_back(sad)
	is_safe = true


func sad(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	if is_active(tile_map_layer, coords):
		player.stats.inc_all(decrement)
		Jukebox.play_sound("bumpsad")
		deactivate(tile_map_layer, coords)
