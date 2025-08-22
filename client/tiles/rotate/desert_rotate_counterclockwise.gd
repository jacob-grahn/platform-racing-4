extends RotateCounterclockwise
class_name DesertRotateCounterclockwise


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(rotate_player_counterclockwise)
