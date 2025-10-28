extends Push
class_name DesertPush


func init():
	matter_type = Tile.ACTIVE
	push_atlas_coords = Vector2i(3, 7)
	any_side.push_back(push)
	is_safe = false
