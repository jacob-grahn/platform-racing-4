extends Ice
class_name SpaceIce


func init():
	matter_type = Tile.ACTIVE
	any_side.push_back(freeze)
	is_safe = true
