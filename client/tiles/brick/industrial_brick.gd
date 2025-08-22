extends Brick
class_name IndustrialBrick


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(shatter)
	is_safe = false
