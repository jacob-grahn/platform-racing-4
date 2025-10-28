extends Push
class_name ClassicPush


func init():
	matter_type = Tile.ACTIVE
	push_atlas_coords = Vector2i(3, 2)
	any_side.push_back(push)
	is_safe = false
