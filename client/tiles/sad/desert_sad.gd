extends Sad
class_name DesertSad


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(sad)
	is_safe = true
