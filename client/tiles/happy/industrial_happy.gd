extends Happy
class_name IndustrialHappy


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(happy)
	is_safe = true
