extends RotateCounterclockwise
class_name IndustrialRotateCounterclockwise


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(rotate_player_counterclockwise)
