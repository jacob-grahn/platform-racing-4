extends Appear
class_name JungleAppear

func init():
	matter_type = Tile.ACTIVE
	atlas_coords = Vector2i(9, 18)
	any_side.push_back(appear)
