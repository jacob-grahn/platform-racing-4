extends Mini
class_name DesertMini


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(shrink)
	is_safe = true
