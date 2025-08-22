extends Sticky
class_name ClassicSticky


func init():
	matter_type = Tile.ACTIVE
	any_side.push_back(stick)
	is_safe = true
