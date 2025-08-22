extends Bounce
class_name IndustrialBounce


func init():
	matter_type = Tile.ACTIVE
	any_side.push_back(bounce)
