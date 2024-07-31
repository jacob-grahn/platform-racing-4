extends Tile
class_name RotateClockwise


func init():
	matter_type = Tile.SOLID
	bump.push_back(rotate_player_clockwise)


func rotate_player_clockwise(player: Node2D, tilemap: Node2D, _coords: Vector2i) -> void:
	player.target_rotation += PI / 2
	if player.target_rotation > PI:
		player.target_rotation -= PI * 2

