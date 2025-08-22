extends Brick
class_name DesertBrick


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(shatter)
	is_safe = false
