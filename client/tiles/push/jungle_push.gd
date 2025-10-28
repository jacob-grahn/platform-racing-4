extends Push
class_name JunglePush


func init():
	matter_type = Tile.ACTIVE
	push_atlas_coords = Vector2i(3, 17)
	any_side.push_back(push)
	is_safe = false
