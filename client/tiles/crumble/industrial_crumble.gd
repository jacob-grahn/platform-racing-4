extends Crumble
class_name IndustrialCrumble


func init():
	matter_type = Tile.ACTIVE
	is_safe = false
	any_side.push_back(crumble)
