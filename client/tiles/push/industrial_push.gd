extends Push
class_name IndustrialPush


func init():
	matter_type = Tile.ACTIVE
	push_atlas_coords = Vector2i(3, 12)
	any_side.push_back(push)
	is_safe = false
