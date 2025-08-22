extends Mine
class_name IndustrialMine


func init():
	matter_type = Tile.ACTIVE
	any_side.push_back(explode)
	is_safe = false
