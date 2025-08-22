extends Tile
class_name CustomStats


var custom_speed: int = 50
var custom_accel: int = 50
var custom_jump: int = 50
var custom_skill: int = 50

func init():
	matter_type = Tile.ACTIVE
	bump.push_back(set_stats)
	is_safe = true


func set_stats(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	if is_active(tile_map_layer, coords):
		player.stats.set_stats(custom_speed, custom_accel, custom_jump, custom_skill)
		deactivate(tile_map_layer, coords)
