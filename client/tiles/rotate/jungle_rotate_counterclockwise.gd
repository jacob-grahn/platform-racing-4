extends RotateCounterclockwise
class_name JungleRotateCounterclockwise


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(rotate_player_counterclockwise)
