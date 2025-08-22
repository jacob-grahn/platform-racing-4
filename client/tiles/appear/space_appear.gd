extends Appear
class_name SpaceAppear

func init():
	matter_type = Tile.ACTIVE
	atlas_coords = Vector2i(9, 23)
	any_side.push_back(appear)
