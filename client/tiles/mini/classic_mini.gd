extends Mini
class_name ClassicMini


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(shrink)
	is_safe = true
