extends RotateCounterclockwise
class_name ClassicRotateCounterclockwise


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(rotate_player_counterclockwise)
