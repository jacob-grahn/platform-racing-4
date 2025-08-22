extends Tile
class_name TimeBlock

var timer_increment: int = 10


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(inc_time)


func inc_time(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	if !is_active(tile_map_layer, coords):
		return
	
	player.emit_signal("increase_time", timer_increment)
	
	# deactivate this tile
	deactivate(tile_map_layer, coords)
