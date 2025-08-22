extends Mini
class_name JungleMini


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(shrink)
	is_safe = true
