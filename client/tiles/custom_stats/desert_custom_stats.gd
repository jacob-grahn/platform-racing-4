extends CustomStats
class_name DesertCustomStats


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(set_stats)
	is_safe = true
