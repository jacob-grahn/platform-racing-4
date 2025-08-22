extends Heart
class_name SpaceHeart


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(shield)
	is_safe = true
