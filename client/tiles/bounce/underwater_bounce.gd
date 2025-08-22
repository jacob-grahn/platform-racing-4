extends Bounce
class_name UnderwaterBounce


func init():
	matter_type = Tile.ACTIVE
	any_side.push_back(bounce)
