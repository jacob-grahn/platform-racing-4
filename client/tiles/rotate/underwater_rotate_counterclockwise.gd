extends RotateCounterclockwise
class_name UnderwaterRotateCounterclockwise


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(rotate_player_counterclockwise)
