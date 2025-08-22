extends RotateClockwise
class_name IndustrialRotateClockwise


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(rotate_player_clockwise)
