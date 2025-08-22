extends Mega
class_name SpaceMega


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(grow)
	is_safe = true
