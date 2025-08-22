extends Appear
class_name UnderwaterAppear

func init():
	matter_type = Tile.ACTIVE
	atlas_coords = Vector2i(9, 28)
	any_side.push_back(appear)
