extends Sad
class_name SpaceSad


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(sad)
	is_safe = true
