extends RotateClockwise
class_name ClassicRotateClockwise


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(rotate_player_clockwise)
