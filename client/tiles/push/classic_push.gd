extends Push
class_name ClassicPush


func init():
	matter_type = Tile.ACTIVE
	any_side.push_back(push)
	is_safe = false
