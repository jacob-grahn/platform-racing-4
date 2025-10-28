extends Push
class_name UnderwaterPush


func init():
	matter_type = Tile.ACTIVE
	push_atlas_coords = Vector2i(3, 27)
	any_side.push_back(push)
	is_safe = false
