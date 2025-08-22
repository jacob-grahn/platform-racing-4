extends Mega
class_name UnderwaterMega


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(grow)
	is_safe = true
