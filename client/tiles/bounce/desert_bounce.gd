extends Bounce
class_name DesertBounce


func init():
	matter_type = Tile.ACTIVE
	any_side.push_back(bounce)
