extends Appear
class_name ClassicAppear

func init():
	matter_type = Tile.ACTIVE
	atlas_coords = Vector2i(9, 3)
	any_side.push_back(appear)
