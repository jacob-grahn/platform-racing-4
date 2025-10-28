extends Tile
class_name CustomStats


var custom_speed: int = default_custom_stats[0]
var custom_accel: int = default_custom_stats[1]
var custom_jump: int = default_custom_stats[2]
var custom_skill: int = default_custom_stats[3]

func init():
	matter_type = Tile.ACTIVE
	bump.push_back(set_stats)
	is_safe = true


func set_stats(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	if is_active(tile_map_layer, coords):
		player.stats.set_stats(custom_speed, custom_accel, custom_jump, custom_skill)
		deactivate(tile_map_layer, coords)
