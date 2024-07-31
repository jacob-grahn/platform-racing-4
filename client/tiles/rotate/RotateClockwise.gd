extends Tile
class_name RotateClockwise


func init():
	matter_type = Tile.SOLID
	bump.push_back(rotate_player_clockwise)


func rotate_player_clockwise(player: Node2D, tilemap: Node2D, _coords: Vector2i) -> void:
	player.target_rotation += PI / 2
	if abs(player.target_rotation - PI) < 0.001:
		player.target_rotation = PI - 0.00001
	elif player.target_rotation > PI:
		player.target_rotation -= PI * 2
		player.rotation -= PI * 2

