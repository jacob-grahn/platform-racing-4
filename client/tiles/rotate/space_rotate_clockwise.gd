extends RotateClockwise
class_name SpaceRotateClockwise


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(rotate_player_clockwise)
