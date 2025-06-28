extends Tile
class_name RotateClockwise


func init():
	matter_type = Tile.SOLID
	bump.push_back(rotate_player_clockwise)


func rotate_player_clockwise(player: Node2D, tile_map: Node2D, coords: Vector2i) -> void:
	if cooldown(tile_map, coords, 1):
		return
		
	player.gravity.target_rotation += PI / 2
	if abs(player.gravity.target_rotation - PI) < 0.001:
		player.gravity.target_rotation = PI - 0.00001
	elif player.gravity.target_rotation > PI:
		player.gravity.target_rotation -= PI * 2
		player.gravity.rotation -= PI * 2
