extends Bounce
class_name SpaceBounce


func init():
	matter_type = Tile.ACTIVE
	any_side.push_back(bounce)
