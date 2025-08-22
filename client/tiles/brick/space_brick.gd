extends Brick
class_name SpaceBrick


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(shatter)
	is_safe = false
