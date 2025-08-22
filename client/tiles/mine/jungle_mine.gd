extends Mine
class_name JungleMine


func init():
	matter_type = Tile.ACTIVE
	any_side.push_back(explode)
	is_safe = false
