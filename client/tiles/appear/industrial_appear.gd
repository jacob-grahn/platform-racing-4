extends Appear
class_name IndustrialAppear

func init():
	matter_type = Tile.ACTIVE
	atlas_coords = Vector2i(9, 13)
	any_side.push_back(appear)
