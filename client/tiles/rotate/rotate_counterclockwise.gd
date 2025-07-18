extends Tile
class_name RotateCounterclockwise


func init():
	matter_type = Tile.SOLID
	bump.push_back(rotate_player_counterclockwise)


func rotate_player_counterclockwise(player: Node2D, tile_map_layer: Node2D, coords: Vector2i) -> void:
	if cooldown(tile_map_layer, coords, 1):
		return
		
	player.gravity.target_rotation -= PI / 2
	if abs(player.gravity.target_rotation + PI) < 0.001:
		player.gravity.target_rotation = -PI + 0.00001
	elif player.gravity.target_rotation < -PI:
		player.gravity.target_rotation += PI * 2
		player.gravity.rotation += PI * 2
