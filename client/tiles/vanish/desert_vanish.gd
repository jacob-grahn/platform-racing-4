extends Vanish
class_name DesertVanish


func init():
	matter_type = Tile.ACTIVE
	any_side.push_back(vanish)
	is_safe = false
